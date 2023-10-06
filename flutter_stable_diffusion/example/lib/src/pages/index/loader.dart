import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion/flutter_stable_diffusion.dart';
import 'package:flutter_stable_diffusion_core_ml/flutter_stable_diffusion_core_ml.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';
import 'package:flutter_stable_diffusion_example/src/services/model_service.dart';

import 'controller.dart';

class IndexPageModelLoader with DependencyInjectionService, MvcService {
  late final _modelService = getService<ModelService>();
  bool loaded = false;
  bool loading = false;
  bool cancelLoading = false;
  FlutterStableDiffusionPipeline? stableDiffusionPipeline;

  ModelInfo? _model;
  Completer? _cancelCompleter;

  Future switchModel(ModelInfo model) async {
    if (loading) {
      cancelLoading = true;
      await _cancelCompleter?.future;
    }
    await stableDiffusionPipeline?.dispose();
    stableDiffusionPipeline = null;

    _model = model;
    loaded = false;
    cancelLoading = false;
    loading = false;
  }

  Future load() async {
    try {
      await _cancelCompleter?.future;
      await stableDiffusionPipeline?.dispose();
      stableDiffusionPipeline = null;

      _cancelCompleter = Completer();
      late final PlatformStableDiffusionPipelineCreationParams params;
      if (Platform.isIOS || Platform.isMacOS) {
        params = CoreMlStableDiffusionPipelineCreationParams(
          modelPath: _modelService.modelResourcePath(_model!),
        );
      } else {
        throw "Unsupported platform.";
      }
      stableDiffusionPipeline = FlutterStableDiffusionPipeline(params);
      loading = true;
      update();
      await WidgetsBinding.instance.endOfFrame;
      await stableDiffusionPipeline?.loadResources();
      loading = false;
      loaded = true;
      _cancelCompleter?.complete();
      _cancelCompleter = null;
      update();
    } catch (e) {
      getService<IndexPageController>().updateError("model load fail. $e");
      _cancelCompleter?.complete();
      _cancelCompleter = null;
      loaded = false;
      loading = false;
      cancelLoading = false;
      update();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Future(
      () async {
        await _cancelCompleter?.future;
        stableDiffusionPipeline?.dispose();
      },
    );
  }
}
