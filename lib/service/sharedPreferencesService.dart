import 'dart:convert';
import 'package:flutter/material.dart';

// import 'package:snap_journey/service/submitRating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<String> getUser() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('username') ?? '';
  }

  static Future<void> setUser(String s) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('username', s);
  }

  static Future<bool> getLang() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool('lang') ?? false;
  }

  static Future<void> setLang(bool l) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool('lang', true);
  }

  static Future<bool> getPermission() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool('permission') ?? false;
  }

  static Future<void> setPermission(bool l) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool('permission', true);
  }

  static Future<String> getTips() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('tips') ?? '';
  }

  static Future<void> setTips(String name) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('tips', name);
  }

  static Future<String> getGfName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('gfname') ?? '';
  }

  static Future<void> setGfName(String name) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('gfname', name);
  }

  static Future<String> getYourInterests() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('yourInterests') ?? '';
  }

  static Future<void> setYourInterests(String name) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('yourInterests', name);
  }

  static Future<int> getIntValue() async {
    final SharedPreferences prefs = await _prefs;
    final int storedValue = prefs.getInt('intValue') ?? 0;
    final int timestamp = prefs.getInt('intValueTimestamp') ?? 0;

    if (DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))
            .inHours >
        24) {
      await prefs.remove('intValue');
      await prefs.remove('intValueTimestamp');
      return 0;
    }

    return storedValue;
  }

  static Future<void> setIntValue(int value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('intValue', value);
    await prefs.setInt(
      'intValueTimestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<int> getCreditValue(String coinvalueName) async {
    final SharedPreferences prefs = await _prefs;
    final int storedValue = prefs.getInt(coinvalueName) ?? 0;
    return storedValue;
  }

  static Future<void> setCreditValue(
    int coinvalue,
    String coinvalueName,
  ) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(coinvalueName, coinvalue);
  }

  static const String videoStatusKey = 'videoStatus';

  static Future<void> setVideoStatus(String videoPath, String status) async {
    final SharedPreferences prefs = await _prefs;
    final Map<String, String> videoStatusMap = await getVideoStatusMap();

    videoStatusMap[videoPath] = status;

    final String jsonMap = jsonEncode(videoStatusMap);
    prefs.setString(videoStatusKey, jsonMap);
  }

  static Future<Map<String, String>> getVideoStatusMap() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonMap = prefs.getString(videoStatusKey);

    if (jsonMap != null) {
      final Map<String, String> videoStatusMap = Map<String, String>.from(
        jsonDecode(jsonMap),
      );
      return videoStatusMap;
    } else {
      return {};
    }
  }

  static Future<String?> getAudioUrl() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('audioUrl');
  }

  static Future<void> setAudioUrl(String? url) async {
    final SharedPreferences prefs = await _prefs;
    if (url != null) {
      await prefs.setString('audioUrl', url);
    } else {
      await prefs.remove('audioUrl');
    }
  }

  static Future<String?> getImageUrl() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('imageUrl');
  }

  static Future<void> setImageUrl(String? url) async {
    final SharedPreferences prefs = await _prefs;
    if (url != null) {
      await prefs.setString('imageUrl', url);
    } else {
      await prefs.remove('imageUrl');
    }
  }

  static Future<List<String>> getPendingVideoId(String idListName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(idListName) ?? [];
  }

  static Future<void> savePendingVideoId(
    String videoId,
    String idListName,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> videoList = prefs.getStringList(idListName) ?? [];
    videoList.add(videoId);
    await prefs.setStringList(idListName, videoList);
  }

  static Future<void> removePendingVideoId(
    String videoUrl,
    String idListName,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> videoList = prefs.getStringList(idListName) ?? [];
    videoList.remove(videoUrl);
    await prefs.setStringList(idListName, videoList);
  }

  static Future<void> clearPendingVideos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('PendingVideo');
  }

  static Future<void> saveAudioItem(
    Map<String, dynamic> audioItem,
    String itemId,
  ) async {
    final SharedPreferences prefs = await _prefs;
    List<String> audioItems = prefs.getStringList('audioItems') ?? [];
    audioItems.add(itemId);
    await prefs.setStringList('audioItems', audioItems);
    await prefs.setString('audioItem_$itemId', jsonEncode(audioItem));
  }

  static Future<List<Map<String, dynamic>>> getAudioItems() async {
    final SharedPreferences prefs = await _prefs;
    List<String> audioItems = prefs.getStringList('audioItems') ?? [];
    List<Map<String, dynamic>> items = [];
    for (String itemId in audioItems) {
      String? itemData = prefs.getString('audioItem_$itemId');
      if (itemData != null) {
        items.add(jsonDecode(itemData));
      }
    }
    return items;
  }

  static Future<void> removeAudioItem(String itemId) async {
    final SharedPreferences prefs = await _prefs;
    List<String> audioItems = prefs.getStringList('audioItems') ?? [];
    audioItems.remove(itemId);
    await prefs.setStringList('audioItems', audioItems);
    await prefs.remove('audioItem_$itemId');
  }

  static Future<int> getToolUsageCount(String toolName) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt('${toolName}_usageCount') ?? 0;
  }

  static Future<void> setToolUsageCount(String toolName, int count) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt('${toolName}_usageCount', count);
  }

  static Future<void> incrementToolUsage(String toolName) async {
    final int currentCount = await getToolUsageCount(toolName);
    await setToolUsageCount(toolName, currentCount + 1);
  }

  static Future<bool> canUseTool(String toolName, int freeusecount) async {
    final int usageCount = await getToolUsageCount(toolName);
    return usageCount < freeusecount;
  }

  static Future<int> getSaveCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('video_save_count') ?? 0;
  }

  static Future<int> incrementSaveCount() async {
    final prefs = await SharedPreferences.getInstance();
    int saveCount = prefs.getInt('video_save_count') ?? 0;
    saveCount++;
    await prefs.setInt('video_save_count', saveCount);
    return saveCount;
  }

  static Future<void> incrementSaveCountAndCheck(BuildContext context) async {
    int saveCount = await incrementSaveCount();
    if (saveCount == 1 || saveCount == 3) {
      // SubmitRating().submitRating(context);
    }
  }
}
