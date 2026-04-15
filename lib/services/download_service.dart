import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/downloaded_video.dart';
import '../models/movie.dart';
import 'settings_service.dart';

class DownloadService extends ChangeNotifier {
  static const _kDownloads = 'downloads.items';

  final SettingsService settings;
  final Connectivity _connectivity;

  SharedPreferences? _prefs;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  ConnectivityResult _network = ConnectivityResult.none;
  ConnectivityResult get network => _network;
  bool get isOnWifi => _network == ConnectivityResult.wifi;

  final List<DownloadedVideo> _downloads = [];
  List<DownloadedVideo> get downloads => List.unmodifiable(_downloads);

  bool get canAccessDownloads {
    if (!settings.wifiOnlyDownloads) return true;
    return isOnWifi;
  }

  bool get canDownloadNow {
    if (!settings.wifiOnlyDownloads) return _network != ConnectivityResult.none;
    return isOnWifi;
  }

  DownloadService({required this.settings, Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();

    final initial = await _connectivity.checkConnectivity();
    _network = initial.isEmpty ? ConnectivityResult.none : initial.first;

    _connSub?.cancel();
    _connSub = _connectivity.onConnectivityChanged.listen((results) {
      final current = results.isEmpty ? ConnectivityResult.none : results.first;
      if (current != _network) {
        _network = current;
        notifyListeners();
      }
    });

    final raw = _prefs!.getString(_kDownloads);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List)
            .cast<Map<String, dynamic>>()
            .map(DownloadedVideo.fromJson)
            .toList();
        _downloads
          ..clear()
          ..addAll(list);
      } catch (_) {
        _downloads.clear();
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  bool isDownloaded(int movieId) => _downloads.any((d) => d.movieId == movieId);

  DownloadedVideo? getByMovieId(int movieId) {
    try {
      return _downloads.firstWhere((d) => d.movieId == movieId);
    } catch (_) {
      return null;
    }
  }

  Future<String> _downloadsDirPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${dir.path}${Platform.pathSeparator}downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }

  String _safeFileName(String input) {
    final replaced = input.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return replaced.isEmpty ? 'video' : replaced;
  }

  Future<void> _saveToGallery(String filePath) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final success = await GallerySaver.saveVideo(
      filePath,
      albumName: 'MovieFlix',
    );

    if (success != true) {
      throw StateError(
        'Downloaded in app, but failed to save to phone gallery. '
        'Please allow media/photos permission and try again.',
      );
    }
  }

  Future<void> downloadMovie(Movie movie) async {
    if (!canDownloadNow) {
      throw StateError('Wi-Fi required for download');
    }

    if (_network == ConnectivityResult.none) {
      throw StateError('No internet connection');
    }

    final assetPath = settings.pickQualityUrl(movie.videoUrl);
    final dirPath = await _downloadsDirPath();
    final fileName = '${movie.id}_${_safeFileName(movie.title)}.mp4';
    final filePath = '$dirPath${Platform.pathSeparator}$fileName';

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final bytes = await rootBundle.load(assetPath);
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
    await _saveToGallery(filePath);

    final item = DownloadedVideo(
      movieId: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      sourceUrl: assetPath,
      localPath: filePath,
      downloadedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    _downloads.removeWhere((d) => d.movieId == movie.id);
    _downloads.insert(0, item);
    await _persist();
    notifyListeners();
  }

  Future<void> removeDownload(int movieId) async {
    final item = getByMovieId(movieId);
    _downloads.removeWhere((d) => d.movieId == movieId);
    await _persist();
    notifyListeners();

    if (item != null) {
      final f = File(item.localPath);
      if (await f.exists()) {
        await f.delete();
      }
    }
  }

  Future<void> _persist() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_downloads.map((e) => e.toJson()).toList());
    await p.setString(_kDownloads, jsonStr);
  }

  Future<void> clearAll() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.remove(_kDownloads);

    // Best-effort delete local files
    for (final d in List<DownloadedVideo>.from(_downloads)) {
      final f = File(d.localPath);
      if (await f.exists()) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }

    _downloads.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }
}

