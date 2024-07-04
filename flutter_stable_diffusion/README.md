# flutter_stable_diffusion

[![pub package](https://img.shields.io/pub/v/flutter_stable_diffusion.svg)](https://pub.dev/packages/flutter_stable_diffusion)

A Flutter plugin for generate 'Stable Diffusion' image.

|             | iOS   | macOS    |
|-------------|-------|----------|
| **Support** | 16.2+ | 13.1+    |

If you are able to provide implementations for other platforms, contributions via Pull Requests are welcome.

## Usage

To use this plugin, add `flutter_stable_diffusion` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

## Example

```dart
// create pipeline params
final PlatformStableDiffusionPipelineCreationParams params = PlatformStableDiffusionPipelineCreationParams(modelPath:'your model path');

// create pipeline
final FlutterStableDiffusionPipeline pipeline = FlutterStableDiffusionPipeline(params);

// load resources
await pipeline.loadResources();

// generate params
final PlatformStableDiffusionPipelineGenerateParams generateParams = PlatformStableDiffusionPipelineGenerateParams(
    prompt: "your prompt",
    negativePrompt: "your negative prompt",
    stepCount: 20,
    guidanceScale: 7.5,
);

// generate
final PlatformStableDiffusionPipelineGenerateResult result = await pipeline.generate(generateParams);
```

more detail, see [example][1]

![preview](https://raw.githubusercontent.com/yiiim/flutter_stable_diffusion/master/flutter_stable_diffusion/md_assets/preview.png)

[1]: ./example