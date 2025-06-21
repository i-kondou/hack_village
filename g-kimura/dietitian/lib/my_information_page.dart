import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyInformationPage extends StatefulWidget {
  @override
  _MyInformationPageState createState() => _MyInformationPageState();
}

class _MyInformationPageState extends State<MyInformationPage> {
  List<String> keys = ['名前', '年齢', '性別', '身長 (cm)', '体重 (kg)'];
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // 各キーに対応するコントローラーを初期化
    for (var key in keys) {
      _controllers[key] = TextEditingController();
    }
    _load();
  }

  // 各コントローラーを破棄
  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // データの保存処理
  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> data = [
      {for (var key in keys) key: _controllers[key]!.text},
    ];
    await prefs.setString('data', jsonEncode(data));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('保存しました')));
  }

  // データの読み込み処理
  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('data');
    if (dataString != null) {
      List<dynamic> loaded = jsonDecode(dataString);
      if (loaded.isNotEmpty && loaded[0] is Map<String, dynamic>) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(loaded[0]);
        userData.forEach((key, value) {
          if (_controllers.containsKey(key)) {
            _controllers[key]!.text = value.toString();
          }
        });
      }
      setState(() {});
    }
  }

  // 各要素を表示するウィジェット
  Widget _buildElement(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: TextField(
        controller: _controllers[label],
        decoration: InputDecoration(labelText: label),
        keyboardType:
            ['年齢', '身長 (cm)', '体重 (kg)'].contains(label)
                ? TextInputType.number
                : TextInputType.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('マイ情報')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...keys.map(_buildElement).toList(),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _save, child: Text('保存する')),
          ],
        ),
      ),
    );
  }
}
