import 'package:dietitian/widget/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyInformationPage extends StatefulWidget {
  final bool isFirstLogin;
  const MyInformationPage({super.key, this.isFirstLogin = false});

  @override
  MyInformationPageState createState() => MyInformationPageState();
}

class MyInformationPageState extends State<MyInformationPage> {
  PageState _pageState = PageState.neutral;

  // ユーザー情報
  Map<String, dynamic> userData = {
    "name": "",
    "height": 0.0,
    "weight": 0.0,
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
    if (userData["name"] == null || userData["name"] == "") {
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
    // ページの状態を保存中に変更
    setState(() {
      _pageState = PageState.saving;
    });

    // １．入力データを反映、チェック
    userData["name"] = _controllers["name"]?.text ?? "";
    userData["age"] = int.tryParse(_controllers["age"]?.text ?? "") ?? 0;
    userData["height"] =
        double.tryParse(_controllers["height"]?.text ?? "") ?? 0.0;
    userData["weight"] =
        double.tryParse(_controllers["weight"]?.text ?? "") ?? 0.0;
    userData["sex"] = _selectedGender == '未選択' ? null : _selectedGender;
    if (!_isFormValid()) {
      print('❌ 入力内容に不備があります。');
      return;
    }

    // ２．ユーザー情報登録APIにトークンを渡す
    try {
      final dio = Dio();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await dio.post(
        'https://dietitian-backend--feat-919605860399.us-central1.run.app/user/update',
        data: userData,
        options: Options(
          contentType: 'application/json',
          headers: {"Authorization": 'Bearer ${token ?? ''}'},
        ),
        onSendProgress:
            (sent, total) =>
                print('upload ${(sent / total * 100).toStringAsFixed(1)} %'),
      );

      // ３．リスポンスの確認
      if (response.statusCode == 204) {
        print('✅ ユーザー情報登録に成功しました: ${response.data}');
        _showMessage('保存しました。');

        // 最初の情報登録の場合はホームページへ遷移
        if (widget.isFirstLogin) {
          if (!mounted) {
            print("ページがマウントされていません");
            return;
          }
          Navigator.pushReplacementNamed(context, '/homePage');
        }
      } else {
        print('❌ ユーザー情報登録に失敗しました: ${response.data}');
        _showMessage('保存に失敗しました。もう一度お試しください。');
      }
    } catch (e) {
      print('❌ ユーザー情報登録に失敗しました: $e');
      _showMessage('保存に失敗しました。もう一度お試しください。');
    }

    // ページの状態を通常に戻す
    setState(() {
      _pageState = PageState.neutral;
    });
  }

  // データの読み込み処理
  void _load() async {
    // ページの状態をローディングに変更
    setState(() {
      _pageState = PageState.loading;
    });

    // APIからユーザーデータを取得
    try {
      final dio = Dio();
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await dio.get(
        'https://dietitian-backend--feat-919605860399.us-central1.run.app/user/read',
        options: Options(
          contentType: 'application/json',
          headers: {"Authorization": 'Bearer ${token ?? ''}'},
        ),
      );
      // データを画面に移す
      if (response.data != null) {
        userData = response.data;
        print('✅ ユーザーデータの読み込みに成功しました: $userData');
        // 各コントローラーにデータをセット
        _controllers['name']?.text = userData['name'] ?? '';
        _controllers['age']?.text = userData['age']?.toString() ?? '';
        _controllers['height']?.text = userData['height']?.toString() ?? '';
        _controllers['weight']?.text = userData['weight']?.toString() ?? '';
        _selectedGender =
            ['男性', '女性', 'その他'].contains(userData['sex'])
                ? userData['sex']
                : '未選択';
        setState(() {}); // UIを更新
      }
    } catch (e) {
      print('❌ ユーザーデータの読み込みに失敗しました。: $e');
      _showMessage('ユーザーデータの読み込みに失敗しました。');
    }

    // ページの状態を通常に戻す
    setState(() {
      _pageState = PageState.neutral;
    });
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
              ['age', 'height', 'weight'].contains(label)
                  ? TextInputType.number
                  : TextInputType.text,
        ),
      );
    }
  }

  // 大き目のテキストを表示するウィジェット
  Widget _buildTextField(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // リッチUI用のFlutterコード（MyInformationPage）
    // グラデーション背景 + カード形式の入力 + 見栄え改善
    return Scaffold(
      appBar: AppBar(
        title: widget.isFirstLogin ? null : const Text('マイ情報'),
        automaticallyImplyLeading: widget.isFirstLogin == false,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (widget.isFirstLogin) ...[
                  const SizedBox(height: 30),
                  _buildTextField('こんにちは、'),
                  _buildTextField(
                    FirebaseAuth.instance.currentUser != null
                        ? '${FirebaseAuth.instance.currentUser!.displayName} さん'
                        : 'ユーザーID: ${FirebaseAuth.instance.currentUser!.uid}',
                  ),
                  _buildTextField('あなたのことを教えてください！'),
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...keys.keys.map((key) => _buildElement(key)),
                          const SizedBox(height: 32),
                          switch (_pageState) {
                            PageState.loading => loadingIndicator("読み込み中..."),
                            PageState.saving => loadingIndicator("保存中..."),
                            PageState.neutral => ElevatedButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save),
                              label: const Text('保存する'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================
// ページの状態管理
enum PageState { neutral, loading, saving }
