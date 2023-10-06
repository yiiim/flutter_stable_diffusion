import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/controller.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/downloader.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/generator.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/loader.dart';

class IndexPage extends MvcView<IndexPageController, dynamic> {
  Widget buildInputWidgets(BuildContext context) {
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
            controller: controller.promptTextController,
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
            controller: controller.negativePromptTextController,
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
                  controller: controller.stepCountTextController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      controller.stepCountTextController.value = const TextEditingValue(
                        text: "1",
                        selection: TextSelection(baseOffset: 0, extentOffset: 1),
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
                  controller: controller.scaleTextController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      controller.scaleTextController.value = const TextEditingValue(
                        text: "1",
                        selection: TextSelection(baseOffset: 0, extentOffset: 1),
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
      ],
    );
  }

  @override
  Widget buildView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Stable Diffusion'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: LayoutBuilder(
          builder: (context, view) {
            if (Platform.isIOS || Platform.isMacOS) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  constraints: BoxConstraints(minHeight: view.maxHeight),
                  child: Column(
                    children: [
                      MvcServiceScope<IndexPageGenerator>(
                        builder: (context, service) {
                          return Container(
                            constraints: const BoxConstraints(minHeight: 320),
                            child: service.generateImage != null ? Image.memory(service.generateImage!) : const SizedBox.shrink(),
                          );
                        },
                      ),
                      if (controller.errorMessage != null) Text(controller.errorMessage!, style: const TextStyle(color: Colors.red)),
                      if (controller.models == null) const Text("loading models"),
                      if (controller.models != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            MvcBuilder(
                              id: "models",
                              builder: (context) {
                                return Row(
                                  children: [
                                    const Text("Selected model: "),
                                    Flexible(
                                      child: CupertinoButton(
                                        onPressed: controller.switchingModel ? null : controller.tapSelectModel,
                                        child: Text(controller.selectedModel?.id ?? "unselected"),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            MvcServiceScope<IndexPageModelDownloader>(
                              builder: (context, service) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!service.downloading && !service.downloaded && !service.unziping)
                                      TextButton(
                                        onPressed: controller.tapDownload,
                                        child: const Text("download model"),
                                      ),
                                    if (service.downloading) ...[
                                      const Text("Model downloading..."),
                                      Row(
                                        children: [
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 120),
                                            child: MvcBuilder(
                                              id: "downloadProgressText",
                                              builder: (context) => Text(service.downloadProgressText ?? ""),
                                            ),
                                          ),
                                          if (!service.cancelDownloading)
                                            IconButton(
                                              onPressed: service.cancel,
                                              icon: const Icon(
                                                Icons.cancel,
                                                size: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                    if (service.unziping) ...[
                                      const Text("Model unziping..."),
                                      Row(
                                        children: [
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 120),
                                            child: MvcBuilder(
                                              id: "unzipProgressText",
                                              builder: (context) => Text(service.unzipProgressText ?? ""),
                                            ),
                                          ),
                                          if (!service.canceUnziping)
                                            IconButton(
                                              onPressed: service.cancel,
                                              icon: const Icon(
                                                Icons.cancel,
                                                size: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                            MvcServiceScope<IndexPageModelLoader>(
                              builder: (context, service) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (service.loading || service.cancelLoading) ...[
                                      Text(service.cancelLoading ? "Model cancel loading " : "Model loading..."),
                                      const SizedBox(height: 8),
                                    ],
                                    if (service.loaded) ...[
                                      buildInputWidgets(context),
                                    ],
                                    if (service.loaded)
                                      MvcServiceScope<IndexPageGenerator>(
                                        builder: (context, service) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: !service.generateing && !service.cancelGenerateing ? controller.tapGenerate : null,
                                                      child: const Text("Generate"),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TextButton(
                                                      onPressed: service.generateing && !service.cancelGenerateing ? service.cancel : null,
                                                      child: const Text("Cancel"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (service.generateing)
                                                MvcBuilder(
                                                  id: "generateProgressText",
                                                  builder: (context) => Text(service.generateProgressText ?? ""),
                                                ),
                                              if (service.generateing || service.generateImage != null)
                                                MvcBuilder(
                                                  id: "generateTimingText",
                                                  builder: (context) => Text("Time:${service.generateTimingText ?? ""}"),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: Text("Unsupported platform."),
            );
          },
        ),
      ),
    );
  }
}
