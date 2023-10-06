import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';
import 'package:flutter_stable_diffusion_example/src/services/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class UnzipCancelToken {
  bool _cancel = false;
  void cancel() {
    _cancel = true;
  }

  bool get isCancel => _cancel;
}

class ModelStroageUnzipCancelException implements Exception {}

class ModelStroageService with DependencyInjectionService {
  late final String _modelStorageBasePath;
  late final _logger = getService<Logging>();

  Future<bool> isExsit(ModelInfo model) async {
    return File(join(_modelPath(model), "_model.downloaded")).existsSync();
  }

  Future<bool> stroageWithZipFile(ModelInfo model, String zipFilePath, {UnzipCancelToken? cancelToken, void Function(double progress)? onProgress}) async {
    var modelPath = _modelPath(model);
    try {
      if (!Directory(modelPath).existsSync()) {
        Directory(modelPath).createSync(recursive: true);
      }
      Isolate? il;
      var result = Completer<bool>();
      final resultPort = ReceivePort();
      resultPort.listen(
        (message) {
          if (message is double) {
            if (cancelToken?.isCancel == true) {
              il?.kill();
              result.completeError(ModelStroageUnzipCancelException());
            }
            onProgress?.call(message);
          }
          if (message is bool) {
            result.complete(message);
          }
        },
      );
      void runInIsolate(List<dynamic> args) async {
        SendPort responsePort = args[0];
        String zipFilePath = args[1];
        String modelPath = args[2];

        final inputStream = InputFileStream(zipFilePath);
        final archive = ZipDecoder().decodeBuffer(inputStream);
        int total = archive.files.where((element) => element.isFile).map((e) => e.size).reduce((value, element) => value + element);
        int count = 0;
        for (var file in archive.files) {
          // 忽略下划线开头和点开头的文件或路径
          if (file.name.startsWith(RegExp("(_|\\.)"))) {
            continue;
          }
          if (file.isFile) {
            final outputStream = OutputFileStream('$modelPath/${file.name}');
            file.writeContent(outputStream);
            outputStream.close();
            count += file.size;
            responsePort.send(count / total);
          }
        }
        var downloadedFile = await File(join(modelPath, "_model.downloaded")).create();
        await downloadedFile.writeAsString(basenameWithoutExtension(zipFilePath));
        Isolate.exit(responsePort, true);
      }

      il = await Isolate.spawn(
        runInIsolate,
        [resultPort.sendPort, zipFilePath, modelPath],
      );
      return await result.future;
    } catch (e) {
      _logger.log("stroageZipFile error: $e");
      if (Directory(modelPath).existsSync()) {
        Directory(modelPath).deleteSync(recursive: true);
      }
      if (kDebugMode) rethrow;
      return false;
    }
  }

  String _modelPath(ModelInfo info) {
    return join(_modelStorageBasePath, info.id);
  }

  String modelResourcePath(ModelInfo info) {
    var modelPath = _modelPath(info);
    var downloadedFile = File(join(modelPath, "_model.downloaded"));
    if (downloadedFile.existsSync() == false) {
      throw Exception("model not downloaded");
    }
    var modelDirectoryName = downloadedFile.readAsStringSync();
    return join(modelPath, modelDirectoryName);
  }

  @override
  FutureOr dependencyInjectionServiceInitialize() async {
    _modelStorageBasePath = join((await getApplicationSupportDirectory()).path, "models");
  }
}
