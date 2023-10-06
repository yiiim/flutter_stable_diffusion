import 'package:flutter_stable_diffusion_core_ml/src/core_ml_stable_diffusion_pipeline.dart';
import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

import 'src/core_ml_stable_diffusion_generate_cancel_token.dart';

export 'src/core_ml_stable_diffusion_pipeline_creation_params.dart';
export 'src/core_ml_stable_diffusion_generate_cancel_token.dart';
export 'src/core_ml_stable_diffusion_pipeline.dart';
export 'src/core_ml_stable_diffusion_pipeline_generate_params.dart';
export 'src/core_ml_stable_diffusion_pipeline_generate_result.dart';

class CoreMlStableDiffusionPlatform extends StableDiffusionPlatformInterface {
  static void registerWith() {
    StableDiffusionPlatformInterface.instance = CoreMlStableDiffusionPlatform();
  }

  @override
  PlatformStableDiffusionPipeline createPlatformPipeline(PlatformStableDiffusionPipelineCreationParams params) {
    return CoreMlStableDiffusionPipeline(params);
  }

  @override
  PlatformStableDiffusionPipelineGenerateCancelToken createPlatformPipelineGenerateCancelToken() {
    return CoreMlStableDiffusionGenerateCancelToken();
  }
}
