import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

class CoreMlStableDiffusionPipelineGenerateResult
    extends PlatformStableDiffusionPipelineGenerateResult {
  CoreMlStableDiffusionPipelineGenerateResult({
    this.imageData,
    this.isCancelled = false,
    this.isSuccess = true,
    this.message,
  });
  @override
  final List<int>? imageData;

  @override
  final bool isCancelled;

  @override
  final bool isSuccess;

  @override
  final String? message;
}
