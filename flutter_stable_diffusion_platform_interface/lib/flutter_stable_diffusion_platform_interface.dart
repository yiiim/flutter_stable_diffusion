library flutter_stable_diffusion_platform_interface;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class PlatformStableDiffusionPipelineCreationParams {
  const PlatformStableDiffusionPipelineCreationParams({required this.modelPath});

  final String modelPath;
}

class PlatformStableDiffusionPipelineGenerateParams {
  const PlatformStableDiffusionPipelineGenerateParams({
    required this.prompt,
    required this.negativePrompt,
    required this.stepCount,
    this.seed,
    this.guidanceScale = 7.5,
  });

  final String prompt;
  final String negativePrompt;
  final int stepCount;
  final int? seed;
  final double guidanceScale;
}

abstract class PlatformStableDiffusionPipelineGenerateResult {
  String? get message;
  bool get isSuccess;
  bool get isCancelled;
  List<int>? get imageData;
}

abstract class PlatformStableDiffusionPipelineGenerateCancelToken {
  Future cancel();
}

class PlatformStableDiffusionPipelineGenerateProgress {
  PlatformStableDiffusionPipelineGenerateProgress({required this.step, required this.stepCount});
  final int step;
  final int stepCount;
}

abstract class PlatformStableDiffusionPipeline {
  Future loadResources();
  Future<PlatformStableDiffusionPipelineGenerateResult> generate(
    PlatformStableDiffusionPipelineGenerateParams params, {
    void Function(PlatformStableDiffusionPipelineGenerateProgress progress)? onProgress,
    PlatformStableDiffusionPipelineGenerateCancelToken? cancelToken,
  });
  Future dispose();
}

abstract class StableDiffusionPlatformInterface extends PlatformInterface {
  StableDiffusionPlatformInterface() : super(token: _token);
  static final Object _token = Object();
  static StableDiffusionPlatformInterface? _instance;
  static StableDiffusionPlatformInterface? get instance => _instance;

  static set instance(StableDiffusionPlatformInterface? instance) {
    if (instance == null) {
      throw AssertionError('Platform interfaces can only be set to a non-null instance');
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  PlatformStableDiffusionPipeline createPlatformPipeline(PlatformStableDiffusionPipelineCreationParams params);
  PlatformStableDiffusionPipelineGenerateCancelToken createPlatformPipelineGenerateCancelToken();
}
