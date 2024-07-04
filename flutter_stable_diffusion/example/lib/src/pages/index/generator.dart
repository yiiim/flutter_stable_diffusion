import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion/flutter_stable_diffusion.dart';
import 'package:flutter_stable_diffusion_core_ml/flutter_stable_diffusion_core_ml.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/controller.dart';

import 'loader.dart';

class IndexPageGenerator with DependencyInjectionService, MvcService {
  late final _modelLoader = getService<IndexPageModelLoader>();
  FlutterStableDiffusionPipelineGenerateCancelToken? _cancelToken;
  Timer? _timer;

  bool generateing = false;
  bool cancelGenerateing = false;
  String? generateTimingText;
  String? generateProgressText;
  Uint8List? generateImage;

  Completer? _cancelCompleter;

  Future generate(String prompt, String negativePrompt, int stepCount, {double? scale}) async {
    try {
      await _cancelCompleter?.future;
      if (!_modelLoader.loaded) return;
      generateing = true;
      cancelGenerateing = false;
      generateProgressText = "generating";
      update();
      late PlatformStableDiffusionPipelineGenerateParams generateParams;
      if (Platform.isIOS || Platform.isMacOS) {
        generateParams = CoreMlStableDiffusionPipelineGenerateParams(
          prompt: prompt,
          negativePrompt: negativePrompt,
          stepCount: stepCount,
          guidanceScale: scale ?? 7.5,
        );
      } else {
        throw "Unsupported platform.";
      }
      _cancelCompleter = Completer();
      DateTime startTime = DateTime.now();
      _timer?.cancel();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          generateTimingText = "${DateTime.now().difference(startTime).inSeconds}s";
          querySelector("#generateTimingText")?.update();
        },
      );
      _cancelToken = FlutterStableDiffusionPipelineGenerateCancelToken();
      var result = await _modelLoader.stableDiffusionPipeline!.generate(
        generateParams,
        cancelToken: _cancelToken,
        onProgress: (progress) {
          generateProgressText = "generating ${progress.step}/${progress.stepCount}";
          if (progress.currentImages?.isNotEmpty == true) {
            generateImage = Uint8List.fromList(progress.currentImages!.last);
          }
          update();
          querySelector("#generateProgressText")?.update();
        },
      );
      if (result.isSuccess) {
        if (result.imageData != null) {
          generateImage = Uint8List.fromList(result.imageData!);
        }
        generateTimingText = "${DateTime.now().difference(startTime).inSeconds}s";
      } else {
        if (result.isCancelled) {
          getService<IndexPageController>().updateError("generate cancelled");
        } else {
          getService<IndexPageController>().updateError("generate failed, ${result.message ?? ""}");
        }
        generateTimingText = null;
      }
      generateing = false;
      cancelGenerateing = false;
      generateProgressText = null;
      update();
    } catch (e) {
      getService<IndexPageController>().updateError("generate failed, $e");
      generateing = false;
      cancelGenerateing = false;
      generateProgressText = null;
      generateTimingText = null;
      update();
    } finally {
      _timer?.cancel();
      _cancelCompleter?.complete();
      _cancelCompleter = null;
    }
  }

  Future cancel() async {
    if (generateing) {
      cancelGenerateing = true;
      _cancelToken?.cancel();
    }
    await _cancelCompleter?.future;
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    if (generateing) {
      _cancelToken?.cancel();
    }
  }
}
