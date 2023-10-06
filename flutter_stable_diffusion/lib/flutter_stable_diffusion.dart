// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

export 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';

class FlutterStableDiffusionPipelineGenerateCancelToken {
  FlutterStableDiffusionPipelineGenerateCancelToken._(PlatformStableDiffusionPipelineGenerateCancelToken platformCancelTork) : _platformCancelToken = platformCancelTork;
  final PlatformStableDiffusionPipelineGenerateCancelToken _platformCancelToken;
  factory FlutterStableDiffusionPipelineGenerateCancelToken({PlatformStableDiffusionPipelineGenerateCancelToken? platformCancelToken}) {
    return FlutterStableDiffusionPipelineGenerateCancelToken._(
      platformCancelToken ?? StableDiffusionPlatformInterface.instance!.createPlatformPipelineGenerateCancelToken(),
    );
  }

  Future cancel() {
    return _platformCancelToken.cancel();
  }
}

class FlutterStableDiffusionPipeline {
  FlutterStableDiffusionPipeline._(PlatformStableDiffusionPipeline platformPipeline) : _platformPipeline = platformPipeline;
  final PlatformStableDiffusionPipeline _platformPipeline;

  factory FlutterStableDiffusionPipeline(PlatformStableDiffusionPipelineCreationParams creationParams) {
    return FlutterStableDiffusionPipeline._(
      StableDiffusionPlatformInterface.instance!.createPlatformPipeline(
        creationParams,
      ),
    );
  }
  Future<PlatformStableDiffusionPipelineGenerateResult> generate(
    PlatformStableDiffusionPipelineGenerateParams params, {
    void Function(PlatformStableDiffusionPipelineGenerateProgress progress)? onProgress,
    FlutterStableDiffusionPipelineGenerateCancelToken? cancelToken,
  }) {
    return _platformPipeline.generate(
      params,
      onProgress: onProgress,
      cancelToken: cancelToken?._platformCancelToken,
    );
  }

  Future loadResources() {
    return _platformPipeline.loadResources();
  }

  Future dispose() {
    return _platformPipeline.dispose();
  }
}
