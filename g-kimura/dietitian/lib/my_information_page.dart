import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class MyInformationPage extends StatefulWidget {
  const MyInformationPage({super.key});

  @override
  MyInformationPageState createState() => MyInformationPageState();
}

class MyInformationPageState extends State<MyInformationPage> {
  // ユーザー情報
  Map<String, dynamic> userData = {
    "id_token": "string",
    "name": "string",
    "height": 0,
    "weight": 0,
    "age": 0,
    "sex": "string",
  };

  // キーと表示名のマッピング
  Map<String, dynamic> keys = {
    'name': '名前',
    'age': '年齢',
    'sex': '性別',
    'height (cm)': '身長 (cm)',
    'weight (kg)': '体重 (kg)',
  };
  final Map<String, TextEditingController> _controllers = {};
  String _selectedGender = '未選択';

  @override
  void initState() {
    super.initState();
    // 各キーに対応するコントローラーを初期化
    for (var key in userData.keys) {
      if (key != 'sex') {
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

  // 成功失敗の表示
  void _showMessage(String message) {
    if (!mounted) {
      print("ページがマウントされていません");
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // データの保存処理
  void _save() async {
    // ユーザー情報登録APIにトークンを渡す
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://dietitian-backend--main-919605860399.us-central1.run.app/dummy/user/update',
        data: userData,
        options: Options(contentType: 'application/json'),
        onSendProgress:
            (sent, total) =>
                print('upload ${(sent / total * 100).toStringAsFixed(1)} %'),
      );
      // 成功すると全く同じデータが返ってくる
      final isSame =
          response.data['id_token'] == userData['id_token'] &&
          response.data['name'] == userData['name'] &&
          response.data['height'] == userData['height'] &&
          response.data['weight'] == userData['weight'] &&
          response.data['age'] == userData['age'] &&
          response.data['sex'] == userData['sex'];
      if (isSame) {
        print('✅ ユーザー情報登録に成功しました');
        _showMessage('保存しました。');
        //ホーム画面に戻る
        if (!mounted) {
          print("ページがマウントされていません");
          return;
        }
        Navigator.pop(context);
      } else {
        print('❌ ユーザー情報登録に失敗しました: ${response.data}');
        _showMessage('保存に失敗しました。もう一度お試しください。');
      }
    } catch (e) {
      print('❌ ユーザー情報登録に失敗しました: $e');
      _showMessage('保存に失敗しました。もう一度お試しください。');
    }
  }

  // データの読み込み処理
  void _load() async {
    // APIからユーザーデータを取得
    // エンドポイント未実装
  }

  // 各要素を表示するウィジェット
  Widget _buildElement(String label) {
    if (label == 'sex') {
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
          decoration: InputDecoration(labelText: keys[label]),
          keyboardType:
              ['age', 'height (cm)', 'weight (kg)'].contains(label)
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
            ...keys.keys.map(_buildElement),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _save, child: Text('保存する')),
          ],
        ),
      ),
    );
  }
}
