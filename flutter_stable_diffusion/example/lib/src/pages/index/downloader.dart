import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_mvc/flutter_mvc.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';
import 'package:flutter_stable_diffusion_example/src/pages/index/controller.dart';
import 'package:flutter_stable_diffusion_example/src/services/model_service.dart';
import 'package:flutter_stable_diffusion_example/src/services/model_stroage_service.dart';

class IndexPageModelDownloader with DependencyInjectionService, MvcService {
  late final _modelService = getService<ModelService>();
  ModelDownloadCancelToken? _downloadCancelToken;

  bool unziping = false;
  bool canceUnziping = false;
  bool downloaded = false;
  bool downloading = false;
  bool cancelDownloading = false;

  String? downloadProgressText;
  String? unzipProgressText;

  ModelInfo? _model;
  Completer? _cancelDownloadCompleter;
  Completer? _cancelUnzipCompleter;

  Future switchModel(ModelInfo model) async {
    if (downloading) {
      _downloadCancelToken?.cancelDownload();
      await _cancelDownloadCompleter?.future;
    }
    if (unziping) {
      _downloadCancelToken?.cancelUnzip();
      await _cancelUnzipCompleter?.future;
    }

    _model = model;
    downloading = false;
    unziping = false;
    downloadProgressText = null;
    unzipProgressText = null;
    if (_model != null) {
      downloaded = await _modelService.isDownloaded(_model!);
    }
    update();
  }

  Future cancel() async {
    if (downloading && !cancelDownloading) {
      downloadProgressText = "canceling";
      cancelDownloading = true;
      update();
      _downloadCancelToken?.cancelDownload();
      await _cancelDownloadCompleter?.future;
      downloaded = false;
      cancelDownloading = false;
      downloadProgressText = null;
      update();
    }
    if (unziping && !canceUnziping) {
      unzipProgressText = "canceling";
      canceUnziping = true;
      update();
      _downloadCancelToken?.cancelUnzip();
      await _cancelUnzipCompleter?.future;
      unzipProgressText = null;
      unziping = false;
      canceUnziping = false;
      update();
    }
  }

  Future download() async {
    if (_model == null) return;
    try {
      _downloadCancelToken = ModelDownloadCancelToken();
      downloading = true;
      downloadProgressText = "readying to download";
      update();
      _cancelDownloadCompleter = Completer();
      var result = await _modelService.downloadModel(
        _model!,
        onReceiveProgress: (count, total) {
          if (total > 1024 * 1024 * 1024) {
            downloadProgressText = "${(count / (1024 * 1024 * 1024)).toStringAsFixed(1)}G/${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)}G";
          } else if (total > 1024 * 1024) {
            downloadProgressText = "${(count ~/ (1024 * 1024))}MB/${(total ~/ (1024 * 1024))}MB";
          } else {
            downloadProgressText = "${count ~/ 1024}KB/${total ~/ 1024}KB";
          }
          $("#downloadProgressText").update();
        },
        onUnzipProgress: (progress) {
          unzipProgressText = "${(progress * 100).toStringAsFixed(0)}%";
          if (unziping == false) {
            downloading = false;
            unziping = true;
            _cancelDownloadCompleter?.complete();
            _cancelDownloadCompleter = null;
            _cancelUnzipCompleter = Completer();
            update();
          } else {
            $("#unzipProgressText").update();
          }
        },
        cancelToken: _downloadCancelToken,
      );
      _downloadCancelToken = null;
      _cancelUnzipCompleter?.complete();
      _cancelUnzipCompleter = null;
      downloading = false;
      unziping = false;
      if (result) {
        downloaded = true;
        update();
      } else {
        getService<IndexPageController>().updateError("download fail");
        update();
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        getService<IndexPageController>().updateError("download cancel");
      } else if (e is ModelStroageUnzipCancelException) {
        getService<IndexPageController>().updateError("unzip cancel");
      } else {
        getService<IndexPageController>().updateError("download fail. $e");
      }
      _downloadCancelToken = null;
      _cancelDownloadCompleter?.complete();
      _cancelDownloadCompleter = null;
      _cancelUnzipCompleter?.complete();
      _cancelUnzipCompleter = null;
      unzipProgressText = null;
      downloadProgressText = null;
      downloading = false;
      unziping = false;
      downloaded = false;
      update();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Future(
      () async {
        if (downloading && !cancelDownloading) {
          _downloadCancelToken?.cancelDownload();
        }
        await _cancelDownloadCompleter?.future;
        if (unziping && !canceUnziping) {
          _downloadCancelToken?.cancelUnzip();
        }
        await _cancelUnzipCompleter?.future;
      },
    );
  }
}
