import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';
import 'package:platform_object_channel/platform_object_channel.dart';

class CoreMlStableDiffusionGenerateCancelToken extends PlatformStableDiffusionPipelineGenerateCancelToken {
  CoreMlStableDiffusionGenerateCancelToken();
  final PlatformObjectChannel platformObjectChannel = PlatformObjectChannel(
    'CoreMlStableDiffusionGenerateCancelToken',
  );
  @override
  Future cancel() => platformObjectChannel.invokeMethod("cancel");
}
