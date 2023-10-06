import 'dart:async';

import 'package:flutter_stable_diffusion_core_ml/src/core_ml_stable_diffusion_pipeline_generate_result.dart';
import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';
import 'package:platform_object_channel/platform_object_channel.dart';

import 'core_ml_stable_diffusion_generate_cancel_token.dart';
import 'core_ml_stable_diffusion_pipeline_generate_params.dart';

class CoreMlStableDiffusionPipeline implements PlatformStableDiffusionPipeline {
  CoreMlStableDiffusionPipeline(this.creationParams);
  late final PlatformObjectChannel platformObjectChannel = PlatformObjectChannel(
    'CoreMlStableDiffusionPipeline',
    {
      "modelPath": creationParams.modelPath,
    },
  );
  final PlatformStableDiffusionPipelineCreationParams creationParams;

  @override
  Future loadResources() async {
    await platformObjectChannel.invokeMethod("loadResources");
  }

  @override
  Future dispose() async {
    await platformObjectChannel.invokeMethod("dispose");
  }

  @override
  Future<PlatformStableDiffusionPipelineGenerateResult> generate(
    PlatformStableDiffusionPipelineGenerateParams params, {
    void Function(PlatformStableDiffusionPipelineGenerateProgress progress)? onProgress,
    PlatformStableDiffusionPipelineGenerateCancelToken? cancelToken,
  }) async {
    assert(cancelToken == null || cancelToken is CoreMlStableDiffusionGenerateCancelToken);
    await for (var element in platformObjectChannel.invokeMethodStream(
      "generate",
      {
        "prompt": params.prompt,
        "negativePrompt": params.negativePrompt,
        "stepCount": params.stepCount,
        if (params is CoreMlStableDiffusionPipelineGenerateParams) ...{
          "scheduler": params.scheduler.index,
          "seed": params.seed,
          "guidanceScale": params.guidanceScale,
          "disableSafety": params.disableSafety,
        },
        if (cancelToken != null) "cancelToken": (cancelToken as CoreMlStableDiffusionGenerateCancelToken).platformObjectChannel.ref,
      },
    )) {
      if (element is Map) {
        if (element["event"] == "progress") {
          onProgress?.call(
            PlatformStableDiffusionPipelineGenerateProgress(
              step: element["step"],
              stepCount: element["stepCount"],
              currentImages: (element["currentImages"] as List?)?.map((e) => e as List<int>).toList(),
            ),
          );
        } else if (element["event"] == "done") {
          if (element["isCancel"] == true) {
            return CoreMlStableDiffusionPipelineGenerateResult(isSuccess: false, isCancelled: true);
          } else if (element["image"] is List<int>) {
            return CoreMlStableDiffusionPipelineGenerateResult(
              isSuccess: true,
              imageData: element["image"],
            );
          } else {
            return CoreMlStableDiffusionPipelineGenerateResult(
              isSuccess: false,
              message: element["message"],
            );
          }
        }
      }
    }
    return CoreMlStableDiffusionPipelineGenerateResult(isSuccess: false);
  }
}
