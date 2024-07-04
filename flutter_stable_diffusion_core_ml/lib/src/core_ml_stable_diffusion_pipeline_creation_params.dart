import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

enum CoreMlComputeUnits {
  cpuOnly,
  cpuAndGPU,
  all,
  cpuAndNeuralEngine;
}

class CoreMlStableDiffusionPipelineCreationParams
    extends PlatformStableDiffusionPipelineCreationParams {
  CoreMlStableDiffusionPipelineCreationParams({
    required super.modelPath,
    this.reduceMemory = false,
    this.disableSafety = false,
    this.computeUnits = CoreMlComputeUnits.cpuAndGPU,
  });
  final bool reduceMemory;
  final bool disableSafety;
  final CoreMlComputeUnits computeUnits;
}
