import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_stable_diffusion_platform_interface/flutter_stable_diffusion_platform_interface.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'idle';
  late final TextEditingController _promptTextController =
      TextEditingController();
  late final TextEditingController _negativePromptTextController =
      TextEditingController();
  late final TextEditingController _stepCountTextController =
      TextEditingController(text: "20");
  late final TextEditingController _scaleTextController =
      TextEditingController(text: "7.5");
  List<int>? _imageData;
  bool _isLoaded = false;
  bool _generateing = false;
  bool _cancelGenerateing = false;
  ValueNotifier<String> _generateProgressValue = ValueNotifier<String>('');

  PlatformStableDiffusionPipeline? _pipline;
  PlatformStableDiffusionPipelineGenerateCancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
  }

  void tapGenerate() async {
    if (_pipline == null ||
        _isLoaded == false ||
        _promptTextController.text.isEmpty) {
      return;
    }
    try {
      setState(() {
        _generateing = true;
        _cancelGenerateing = false;
        _status = 'generating';
      });
      _generateProgressValue.value = 'generating';
      _cancelToken = StableDiffusionPlatformInterface.instance!
          .createPlatformPipelineGenerateCancelToken();
      var result = await _pipline!.generate(
        PlatformStableDiffusionPipelineGenerateParams(
          prompt: _promptTextController.text,
          negativePrompt: _negativePromptTextController.text,
          stepCount: int.parse(_stepCountTextController.text),
          guidanceScale: double.parse(_scaleTextController.text),
        ),
        onProgress: (progress) async {
          _generateProgressValue.value =
              "${progress.step}/${progress.stepCount}";
        },
        cancelToken: _cancelToken,
      );
      if (result.isSuccess) {
        setState(() {
          _generateing = false;
          _cancelGenerateing = false;
          _imageData = result.imageData;
          _status = 'Success';
        });
      } else if (result.isCancelled) {
        setState(() {
          _generateing = false;
          _cancelGenerateing = false;
          _status = 'Cancelled';
        });
      } else {
        setState(() {
          _generateing = false;
          _cancelGenerateing = false;
          _status = '${result.message}';
        });
      }
    } catch (e) {
      await _cancelToken?.cancel();
      setState(
        () {
          _generateing = false;
          _cancelGenerateing = false;
          _status = 'generate fail, $e';
        },
      );
    }
  }

  void tapCancel() async {
    setState(() {
      _cancelGenerateing = true;
      _status = 'cancelling';
    });
    _cancelToken?.cancel();
  }

  Widget buildGenerateWidgets(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Prompts", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          height: 38,
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _promptTextController,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'prompt',
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          height: 38,
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _negativePromptTextController,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'negative prompt',
            ),
          ),
        ),
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                height: 38,
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _stepCountTextController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      _stepCountTextController.value = const TextEditingValue(
                        text: "1",
                        selection:
                            TextSelection(baseOffset: 0, extentOffset: 1),
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    prefix: Text("step count:"),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              color: Theme.of(context).dividerColor,
              height: 28,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                height: 38,
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _scaleTextController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      _scaleTextController.value = const TextEditingValue(
                        text: "1",
                        selection:
                            TextSelection(baseOffset: 0, extentOffset: 1),
                      );
                    }
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    prefix: Text("guidance scale:"),
                    hintText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed:
                    !_generateing && !_cancelGenerateing ? tapGenerate : null,
                child: const Text("Generate"),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed:
                    _generateing && !_cancelGenerateing ? tapCancel : null,
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: _generateProgressValue,
          builder: (context, value, child) {
            return Text(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  try {
                    var result = await FilePicker.platform.getDirectoryPath();
                    if (result != null) {
                      setState(() {
                        _isLoaded = false;
                        _status = 'loading';
                      });
                      await _cancelToken?.cancel();
                      await _pipline?.dispose();
                      _pipline = StableDiffusionPlatformInterface.instance!
                          .createPlatformPipeline(
                        PlatformStableDiffusionPipelineCreationParams(
                            modelPath: result),
                      );
                      await _pipline?.loadResources();
                      setState(() {
                        _isLoaded = true;
                        _status = 'loaded';
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _status = 'model load fail, $e';
                      _pipline = null;
                      _isLoaded = false;
                    });
                  }
                },
                child: const Text("picker model"),
              ),
              if (_imageData != null)
                Image.memory(Uint8List.fromList(_imageData!)),
              Text('current status: $_status\n'),
              if (_isLoaded) buildGenerateWidgets(context),
            ],
          ),
        ),
      ),
    );
  }
}
