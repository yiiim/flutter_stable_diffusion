# flutter_stable_diffusion_platform_interface

A common platform interface for the [`flutter_stable_diffusion`][1] plugin.

This interface allows platform-specific implementations of the `flutter_stable_diffusion`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `flutter_stable_diffusion`, extend
[`StableDiffusionPlatformInterface`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`StableDiffusionPlatformInterface` by calling
`PlatformObjectChannelInterface.instance = MyPlatformObjectChannel()`.

[1]: ../flutter_stable_diffusion
[2]: lib/flutter_stable_diffusion_platform_interface.dart