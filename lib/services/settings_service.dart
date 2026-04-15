import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_profile.dart';

enum VideoQuality { low, medium, high }

class SettingsService extends ChangeNotifier {
  static const _kWifiOnlyDownloads = 'settings.wifiOnlyDownloads';
  static const _kAutoplayNext = 'settings.autoplayNextEpisode';
  static const _kVideoQuality = 'settings.videoQuality';
  static const _kProfiles = 'settings.profiles';

  static const _defaultProfiles = <AppProfile>[
    AppProfile(id: 'p1', name: 'Main'),
    AppProfile(id: 'p2', name: 'Kids'),
  ];

  SharedPreferences? _prefs;
  bool _isLoaded = false;

  bool _wifiOnlyDownloads = true;
  bool _autoplayNextEpisode = true;
  VideoQuality _videoQuality = VideoQuality.high;
  List<AppProfile> _profiles = [..._defaultProfiles];

  bool get isLoaded => _isLoaded;

  bool get wifiOnlyDownloads => _wifiOnlyDownloads;
  bool get autoplayNextEpisode => _autoplayNextEpisode;
  VideoQuality get videoQuality => _videoQuality;
  List<AppProfile> get profiles => List.unmodifiable(_profiles);

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final p = _prefs!;

    _wifiOnlyDownloads = p.getBool(_kWifiOnlyDownloads) ?? true;
    _autoplayNextEpisode = p.getBool(_kAutoplayNext) ?? true;

    final qualityStr = p.getString(_kVideoQuality) ?? VideoQuality.high.name;
    _videoQuality = VideoQuality.values.firstWhere(
      (v) => v.name == qualityStr,
      orElse: () => VideoQuality.high,
    );

    final profilesJson = p.getString(_kProfiles);
    if (profilesJson != null && profilesJson.trim().isNotEmpty) {
      try {
        final list = (jsonDecode(profilesJson) as List)
            .cast<Map<String, dynamic>>()
            .map(AppProfile.fromJson)
            .where((p) => p.name.trim().isNotEmpty)
            .toList();
        if (list.isNotEmpty) _profiles = list;
      } catch (_) {
        _profiles = [..._defaultProfiles];
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setWifiOnlyDownloads(bool value) async {
    _wifiOnlyDownloads = value;
    notifyListeners();
    await _prefs?.setBool(_kWifiOnlyDownloads, value);
  }

  Future<void> setAutoplayNextEpisode(bool value) async {
    _autoplayNextEpisode = value;
    notifyListeners();
    await _prefs?.setBool(_kAutoplayNext, value);
  }

  Future<void> setVideoQuality(VideoQuality value) async {
    _videoQuality = value;
    notifyListeners();
    await _prefs?.setString(_kVideoQuality, value.name);
  }

  Future<void> addProfile(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _profiles = [..._profiles, AppProfile(id: id, name: trimmed)];
    notifyListeners();
    await _persistProfiles();
  }

  Future<void> updateProfile({required String id, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _profiles = _profiles
        .map((p) => p.id == id ? AppProfile(id: p.id, name: trimmed) : p)
        .toList();
    notifyListeners();
    await _persistProfiles();
  }

  Future<void> deleteProfile(String id) async {
    if (_profiles.length <= 1) return;
    _profiles = _profiles.where((p) => p.id != id).toList();
    if (_profiles.isEmpty) _profiles = [..._defaultProfiles];
    notifyListeners();
    await _persistProfiles();
  }

  Future<void> _persistProfiles() async {
    final data = jsonEncode(_profiles.map((e) => e.toJson()).toList());
    await _prefs?.setString(_kProfiles, data);
  }

  String pickQualityUrl(String baseUrl) {
    switch (_videoQuality) {
      case VideoQuality.low:
        return 'assets/videos/video_1.mp4';
      case VideoQuality.medium:
        return 'assets/videos/video_2.mp4';
      case VideoQuality.high:
        return 'assets/videos/video_3.mp4';
    }
  }

  Future<void> clearAll() async {
    _wifiOnlyDownloads = true;
    _autoplayNextEpisode = true;
    _videoQuality = VideoQuality.high;
    _profiles = [..._defaultProfiles];
    notifyListeners();

    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.remove(_kWifiOnlyDownloads);
    await p.remove(_kAutoplayNext);
    await p.remove(_kVideoQuality);
    await p.remove(_kProfiles);
  }
}

