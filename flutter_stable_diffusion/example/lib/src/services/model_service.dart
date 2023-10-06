import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';
import 'package:flutter_stable_diffusion_example/src/services/model_stroage_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_object_channel/platform_object_channel.dart';

class ModelDownloadProgress {
  // final bool downloading;
  // final double total;
  // final double count;

  // final bool unziping;
  // final double unzipProgress;
}

class ModelDownloadCancelToken {
  late final CancelToken _downloadCancelToken = CancelToken();
  late final UnzipCancelToken _unzipCancelToken = UnzipCancelToken();
  void cancelDownload([Object? reason]) {
    _downloadCancelToken.cancel(reason);
  }

  void cancelUnzip() {
    _unzipCancelToken.cancel();
  }
}

class ModelService with DependencyInjectionService {
  late final _modelHelper = PlatformObjectChannel("ModelHelper");
  late final _modelStroageService = getService<ModelStroageService>();
  late final _dio = getService<Dio>();

  Future<List<ModelInfo>> getModels() async {
    var models = await _modelHelper.invokeMethod("getModels");
    if (models is List) {
      return models.map(
        (e) {
          return ModelInfo.fromJson((e as Map).cast<String, dynamic>());
        },
      ).toList();
    }
    throw Exception("getModels error");
  }

  String modelResourcePath(ModelInfo model) {
    return _modelStroageService.modelResourcePath(model);
  }

  Future<bool> isDownloaded(ModelInfo model) async {
    return _modelStroageService.isExsit(model);
  }

  Future<bool> downloadModel(
    ModelInfo model, {
    ModelDownloadCancelToken? cancelToken,
    void Function(int count, int total)? onReceiveProgress,
    void Function(double progress)? onUnzipProgress,
  }) async {
    var tempPath = join((await getTemporaryDirectory()).path, basename(Uri.parse(model.url).path));
    try {
      var result = await _dio.download(
        model.url,
        tempPath,
        cancelToken: cancelToken?._downloadCancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (result.statusCode == 200) {
        await _modelStroageService.stroageWithZipFile(
          model,
          tempPath,
          onProgress: onUnzipProgress,
          cancelToken: cancelToken?._unzipCancelToken,
        );
        return true;
      } else {
        return false;
      }
    } finally {
      if (Directory(tempPath).existsSync()) {
        await Directory(tempPath).delete(recursive: true);
      }
    }
  }
}
