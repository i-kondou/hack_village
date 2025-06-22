// lib/utils/storage_helper.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // データを保存するメソッド
  static Future<void> saveData(Map<String, String> data, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode([data]));
  }

  // データを読み込むメソッド
  static Future<Map<String, String>?> loadData(String key) async {
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
}
