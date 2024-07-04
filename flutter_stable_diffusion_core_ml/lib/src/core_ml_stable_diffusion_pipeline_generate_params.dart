import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

enum CoreMlStableDiffusionScheduler {
  pndmScheduler,
  dpmSolverMultistepScheduler,
}

class CoreMlStableDiffusionPipelineGenerateParams
    extends PlatformStableDiffusionPipelineGenerateParams {
  CoreMlStableDiffusionPipelineGenerateParams({
    required super.prompt,
    super.negativePrompt = "",
    super.stepCount = 20,
    this.scheduler = CoreMlStableDiffusionScheduler.pndmScheduler,
    super.seed = 0,
    super.guidanceScale = 7.5,
    this.disableSafety = false,
    this.cancelToken,
  });
  final CoreMlStableDiffusionScheduler scheduler;
  final bool disableSafety;
  final PlatformStableDiffusionPipelineGenerateCancelToken? cancelToken;
}
