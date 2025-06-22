import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'storage_helper.dart';

class MyInformationPage extends StatefulWidget {
  const MyInformationPage({super.key});

  @override
  MyInformationPageState createState() => MyInformationPageState();
}

class MyInformationPageState extends State<MyInformationPage> {
  // ユーザー情報
  Map<String, dynamic> userData = {
    "id_token": "",
    "name": "",
    "height": 0,
    "weight": 0,
    "age": 0,
    "sex": "",
  };

  // キーと表示名のマッピング
  Map<String, dynamic> keys = {
    'name': '名前',
    'age': '年齢',
    'sex': '性別',
    'height': '身長 (cm)',
    'weight': '体重 (kg)',
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
    _initializeIdToken();
    _load();
  }

  void _initializeIdToken() async {
    final data = await StorageHelper.loadData('google_auth_data');
    setState(() {
      userData['id_token'] = data?['idToken'] ?? "";
    });
  }

  // 各コントローラーを破棄
  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // メッセージの表示
  void _showMessage(String message) {
    if (!mounted) {
      print("ページがマウントされていません");
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar(); // 現在のSnackBarを即座に消す
    messenger.showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  // 全ての情報が入力されているかチェック
  bool _isFormValid() {
    if (userData["id_token"] == null || userData["id_token"] == "") {
      _showMessage('IDが取得できません。');
      return false;
    } else if (userData["name"] == null || userData["name"] == "") {
      _showMessage('名前を入力してください。');
      return false;
    } else if (userData["age"] == null || userData["age"] <= 0) {
      _showMessage('年齢を正しく入力してください。');
      return false;
    } else if (userData["height"] == null || userData["height"] <= 0) {
      _showMessage('身長を正しく入力してください。');
      return false;
    } else if (userData["weight"] == null || userData["weight"] <= 0) {
      _showMessage('体重を正しく入力してください。');
      return false;
    } else if (userData["sex"] == null || userData["sex"] == "") {
      _showMessage('性別を選択してください。');
      return false;
    }
    return true;
  }

  // データの保存処理
  void _save() async {
    // 入力データを反映
    userData["name"] = _controllers["name"]?.text ?? "";
    userData["age"] = int.tryParse(_controllers["age"]?.text ?? "") ?? 0;
    userData["height"] = int.tryParse(_controllers["height"]?.text ?? "") ?? 0;
    userData["weight"] = int.tryParse(_controllers["weight"]?.text ?? "") ?? 0;
    userData["sex"] = _selectedGender == '未選択' ? null : _selectedGender;

    // 入力チェック
    if (!_isFormValid()) {
      print('❌ 入力内容に不備があります。');
      return;
    }

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
        print('✅ ユーザー情報登録に成功しました: ${response.data}');
        _showMessage('保存しました。');
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
