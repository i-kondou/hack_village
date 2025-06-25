import 'package:dietitian/services/storage_helper.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:dietitian/widget/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/show_message.dart';

class MyInformationPage extends StatefulWidget {
  final bool isFirstLogin;
  const MyInformationPage({super.key, this.isFirstLogin = false});

  @override
  MyInformationPageState createState() => MyInformationPageState();
}

class MyInformationPageState extends State<MyInformationPage> {
  PageStatus _pageStatus = PageStatus.neutral;
  void setPageStatus(PageStatus status) {
    setState(() {
      _pageStatus = status;
    });
    print('ページの状態が $status に設定されました。');
  }

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
  Map<String, IconData> icons = {
    'name': Icons.person,
    'age': Icons.calendar_today,
    'sex': Icons.transgender,
    'height': Icons.height,
    'weight': Icons.scale,
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
    if (!widget.isFirstLogin) {
      _load();
    }
  }

  // 各コントローラーを破棄
  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // 全ての情報が入力されているかチェック
  bool _isFormValid() {
    if (userData["name"] == null || userData["name"] == "") {
      showSnackBarMessage('名前を入力してください。', context, mounted);
      return false;
    } else if (userData["age"] == null || userData["age"] <= 0) {
      showSnackBarMessage('年齢を正しく入力してください。', context, mounted);
      return false;
    } else if (userData["height"] == null || userData["height"] <= 0) {
      showSnackBarMessage('身長を正しく入力してください。', context, mounted);
      return false;
    } else if (userData["weight"] == null || userData["weight"] <= 0) {
      showSnackBarMessage('体重を正しく入力してください。', context, mounted);
      return false;
    } else if (userData["sex"] == null || userData["sex"] == "") {
      showSnackBarMessage('性別を選択してください。', context, mounted);
      return false;
    }
    return true;
  }

  // データの保存処理
  void _save() async {
    // ページの状態を保存中に変更
    setPageStatus(PageStatus.saving);

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
      setPageStatus(PageStatus.neutral);
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
      if (!mounted) return;
      if (response.statusCode == 204) {
        print('✅ ユーザー情報登録に成功しました: ${response.data}');
        showSnackBarMessage('保存しました。', context, mounted);

        //本体に「ユーザーデータが保存されていること」を保存する
        StorageHelper.saveString('userdata_saved', 'true');

        // 最初の情報登録の場合はホームページへ遷移
        if (widget.isFirstLogin) {
          Navigator.pushReplacementNamed(context, '/homePage');
        }
      } else {
        print('❌ ユーザー情報登録に失敗しました: ${response.data}');
        showSnackBarMessage('保存に失敗しました。もう一度お試しください。', context, mounted);
      }
    } catch (e) {
      print('❌ ユーザー情報登録に失敗しました: $e');
      showSnackBarMessage('保存に失敗しました。もう一度お試しください。', context, mounted);
    }

    // ページの状態を通常に戻す
    setPageStatus(PageStatus.neutral);
  }

  // データの読み込み処理
  void _load() async {
    // ページの状態をローディングに変更
    setPageStatus(PageStatus.loading);

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
      if (!mounted) return;
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
      //データの読み取りに失敗した場合と、データが元からなかった場合が考えられる。
      print('❌ ユーザーデータの読み込みに失敗しました。またはデータが空です。: $e');
      showSnackBarMessage('ユーザーデータを登録してください。', context, mounted);
    }

    // ページの状態を通常に戻す
    setPageStatus(PageStatus.neutral);
  }

  // 各要素を表示するウィジェット
  Widget _userDataElement(String label) {
    if (label == 'sex') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        child: DropdownButtonFormField<String>(
          value: _selectedGender == '' ? '未選択' : _selectedGender,
          decoration: InputDecoration(
            labelText: '性別',
            icon: Icon(icons[label]),
          ),
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
          decoration: InputDecoration(
            labelText: keys[label],
            icon: Icon(icons[label]),
          ),
          keyboardType:
              ['age', 'height', 'weight'].contains(label)
                  ? TextInputType.number
                  : TextInputType.text,
        ),
      );
    }
  }

  Widget _saveSection() {
    switch (_pageStatus) {
      case PageStatus.loading:
        return Center(child: customLoadingIndicator("読み込み中..."));
      case PageStatus.saving:
        return Center(child: customLoadingIndicator("保存中..."));
      case PageStatus.neutral:
        return customElevatedButton(
          onPressed: _save,
          icon: Icons.save,
          label: '保存する',
          isValid: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backGroundBoxDecoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: widget.isFirstLogin ? null : Text('マイ情報'),
          automaticallyImplyLeading: widget.isFirstLogin == false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              widget.isFirstLogin
                  ? Column(
                    children: [
                      SizedBox(height: 30),
                      customLargeBoldColoredText('はじめまして。', context),
                      customLargeBoldColoredText('あなたのことを教えてください！', context),
                    ],
                  )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...keys.keys.map(_userDataElement),
                    SizedBox(height: 32),
                    _saveSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================
// ページの状態管理
enum PageStatus { neutral, loading, saving }
