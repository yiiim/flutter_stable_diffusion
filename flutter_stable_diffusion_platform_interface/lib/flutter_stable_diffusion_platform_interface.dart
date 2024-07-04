library flutter_stable_diffusion_platform_interface;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// params for create [PlatformStableDiffusionPipeline]
class PlatformStableDiffusionPipelineCreationParams {
  const PlatformStableDiffusionPipelineCreationParams(
      {required this.modelPath});

  /// stable diffusion model path
  final String modelPath;
}

/// params for [PlatformStableDiffusionPipeline.generate]
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

/// result for [PlatformStableDiffusionPipeline.generate]
abstract class PlatformStableDiffusionPipelineGenerateResult {
  /// message
  String? get message;

  /// is success
  bool get isSuccess;

  /// is cancelled
  bool get isCancelled;

  /// image data
  List<int>? get imageData;
}

/// cancel token for [PlatformStableDiffusionPipeline.generate]
abstract class PlatformStableDiffusionPipelineGenerateCancelToken {
  /// cancel generate
  Future cancel();
}

/// progress for [PlatformStableDiffusionPipeline.generate]
class PlatformStableDiffusionPipelineGenerateProgress {
  PlatformStableDiffusionPipelineGenerateProgress({
    required this.step,
    required this.stepCount,
    this.currentImages,
  });
  final int step;
  final int stepCount;
  final List<List<int>>? currentImages;
}

/// pipeline for stable diffusion
abstract class PlatformStableDiffusionPipeline {
  /// load resources
  Future loadResources();

  /// generate images
  ///
  /// [params] params for generate
  /// [onProgress] callback for progress
  /// [cancelToken] cancel token
  Future<PlatformStableDiffusionPipelineGenerateResult> generate(
    PlatformStableDiffusionPipelineGenerateParams params, {
    void Function(PlatformStableDiffusionPipelineGenerateProgress progress)?
        onProgress,
    PlatformStableDiffusionPipelineGenerateCancelToken? cancelToken,
  });

  /// dispose
  Future dispose();
}

abstract class StableDiffusionPlatformInterface extends PlatformInterface {
  StableDiffusionPlatformInterface() : super(token: _token);
  static final Object _token = Object();
  static StableDiffusionPlatformInterface? _instance;
  static StableDiffusionPlatformInterface? get instance => _instance;

  static set instance(StableDiffusionPlatformInterface? instance) {
    if (instance == null) {
      throw AssertionError(
          'Platform interfaces can only be set to a non-null instance');
    }

    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// create [PlatformStableDiffusionPipeline]
  PlatformStableDiffusionPipeline createPlatformPipeline(
      PlatformStableDiffusionPipelineCreationParams params);

  /// create [PlatformStableDiffusionPipelineGenerateCancelToken]
  PlatformStableDiffusionPipelineGenerateCancelToken
      createPlatformPipelineGenerateCancelToken();
}
