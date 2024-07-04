import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion_example/src/pages/dialogs/select_dialog.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';
import 'package:flutter_stable_diffusion_example/src/services/model_service.dart';
import 'downloader.dart';
import 'generator.dart';
import 'loader.dart';
import 'view.dart';

class IndexPageController extends MvcController {
  late final _modelService = getService<ModelService>();
  late final _downloader = getService<IndexPageModelDownloader>();
  late final _loader = getService<IndexPageModelLoader>();
  late final _generator = getService<IndexPageGenerator>();

  late final TextEditingController promptTextController = TextEditingController();
  late final TextEditingController negativePromptTextController = TextEditingController();
  late final TextEditingController stepCountTextController = TextEditingController(text: "20");
  late final TextEditingController scaleTextController = TextEditingController(text: "7.5");

  List<ModelInfo>? models;
  ModelInfo? selectedModel;
  String? errorMessage;
  bool switchingModel = false;

  Future _getModels() async {
    models = await _modelService.getModels();
    update();
    if (models?.isNotEmpty == true) {
      switchModel(models!.first);
    } else {
      querySelector("#models")?.update();
    }
  }

  void switchModel(ModelInfo model) async {
    selectedModel = model;
    switchingModel = true;
    updateError();
    querySelector("#models")?.update();
    await Future.wait(
      [
        _generator.cancel(),
        _downloader.switchModel(model),
        _loader.switchModel(model),
      ],
    );
    switchingModel = false;
    querySelector("#models")?.update();
    if (_downloader.downloaded) {
      await _loader.load();
    }
  }

  void tapSelectModel() async {
    var model = await showSelectModelDialog(context, models ?? []);
    if (model != null && selectedModel != model) {
      switchModel(model);
    }
  }

  void tapDownload() async {
    await _downloader.download();
    updateError();
    if (_downloader.downloaded) {
      await _loader.load();
    }
  }

  void tapGenerate() async {
    updateError();
    var stepCount = int.tryParse(stepCountTextController.text);
    if (stepCount == null) {
      errorMessage = "step count must be a number.";
      update();
      return;
    }
    var scale = double.tryParse(scaleTextController.text);
    if (scale == null) {
      errorMessage = "guidance scale must be a number.";
      update();
      return;
    }
    await _generator.generate(
      promptTextController.text,
      negativePromptTextController.text,
      stepCount,
      scale: scale,
    );
  }

  void updateError([String? error]) {
    errorMessage = error;
    update();
  }

  @override
  void initServices(ServiceCollection collection) {
    super.initServices(collection);
    collection.addSingleton((serviceProvider) => IndexPageModelDownloader());
    collection.addSingleton((serviceProvider) => IndexPageModelLoader());
    collection.addSingleton((serviceProvider) => IndexPageGenerator());
  }

  @override
  void init() {
    super.init();
    _getModels();
  }

  @override
  MvcView view() {
    return IndexPage();
  }
}
