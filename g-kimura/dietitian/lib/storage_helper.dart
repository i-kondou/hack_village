// lib/utils/storage_helper.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // データを保存するメソッド
  static Future<void> saveMap(Map<String, dynamic> data, String key) async {
    final prefs = await SharedPreferences.getInstance();
    // 値をすべて String に変換
    final Map<String, String> stringData = {
      for (var entry in data.entries) entry.key: entry.value.toString(),
    };
    await prefs.setString(key, jsonEncode([stringData]));
  }

  // 単一のキーと値を保存
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // データを読み込むメソッド
  static Future<Map<String, String>?> loadMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString(key);
    if (dataString != null) {
      List<dynamic> loaded = jsonDecode(dataString);
      if (loaded.isNotEmpty && loaded[0] is Map<String, dynamic>) {
        return Map<String, String>.from(loaded[0]);
      }
    }
    return null;
  }

  // 単一のキーから値を読み込む
  static Future<String?> loadString(String key, String defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
}
