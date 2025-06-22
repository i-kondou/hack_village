import 'package:flutter/material.dart';
import 'storage_helper.dart';

class MyInformationPage extends StatefulWidget {
  const MyInformationPage({super.key});

  @override
  MyInformationPageState createState() => MyInformationPageState();
}

class MyInformationPageState extends State<MyInformationPage> {
  List<String> keys = ['名前', '年齢', '性別', '身長 (cm)', '体重 (kg)'];
  final Map<String, TextEditingController> _controllers = {};
  String _selectedGender = '未選択';

  @override
  void initState() {
    super.initState();
    // 各キーに対応するコントローラーを初期化
    for (var key in keys) {
      if (key != '性別') {
        _controllers[key] = TextEditingController();
      }
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
    Map<String, String> data = {
      for (var key in keys)
        if (key == '性別') key: _selectedGender else key: _controllers[key]!.text,
    };
    await StorageHelper.saveData(data, 'my_information');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('保存しました')));
  }

  // データの読み込み処理
  void _load() async {
    final userData = await StorageHelper.loadData('my_information');
    if (userData != null) {
      userData.forEach((key, value) {
        if (key == '性別') {
          _selectedGender = value;
        } else if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value;
        }
      });
      setState(() {});
    }
  }

  // 各要素を表示するウィジェット
  Widget _buildElement(String label) {
    if (label == '性別') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        child: DropdownButtonFormField<String>(
          value: _selectedGender == '' ? '未選択' : _selectedGender,
          decoration: InputDecoration(labelText: '性別'),
          items:
              ['未選択', '男性', '女性', 'その他']
                  .map(
                    (gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedGender = value;
              });
            }
          },
        ),
      );
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('マイ情報')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...keys.map(_buildElement),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _save, child: Text('保存する')),
          ],
        ),
      ),
    );
  }
}
