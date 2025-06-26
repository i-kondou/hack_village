import 'package:dietitian/services/storage_helper.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:dietitian/widget/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/show_message.dart';
import 'package:dietitian/recources/user_data_catalog.dart';
import '../utils/is_all_data_valid.dart';

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

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownOptions = {};
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    for (var key in userDataCatalog.keys) {
      if (userDataCatalog[key]!.inputMethod == InputMethod.dropdown) {
        _dropdownOptions[key] = userDataCatalog[key]!.noData as String;
      } else if (userDataCatalog[key]!.inputMethod == InputMethod.text) {
        _controllers[key] = TextEditingController();
      }
      userData[key] = userDataCatalog[key]!.noData;
    }
    if (!widget.isFirstLogin) {
      _load();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> requestUpdateAPI() async {
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

    bool isSuccess = response.statusCode == 204;
    if (!isSuccess) {
      throw Exception('ユーザー情報登録に失敗: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> requestReadAPI() async {
    final dio = Dio();
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await dio.get(
      'https://dietitian-backend--feat-919605860399.us-central1.run.app/user/read',
      options: Options(
        contentType: 'application/json',
        headers: {"Authorization": 'Bearer ${token ?? ''}'},
      ),
    );
    if (response.data != null) {
      return response.data;
    } else {
      throw Exception('ユーザーデータの読み込みに失敗: ${response.statusCode}');
    }
  }

  void updateUserDataFromDisplay() {
    for (var key in userDataCatalog.keys) {
      if (userDataCatalog[key]!.inputMethod == InputMethod.text) {
        if (_controllers.containsKey(key)) {
          switch (userDataCatalog[key]!.type) {
            case Type.string:
              userData[key] =
                  _controllers[key]?.text ?? userDataCatalog[key]!.noData;
              break;
            case Type.int:
              userData[key] =
                  int.tryParse(_controllers[key]?.text ?? "") ??
                  userDataCatalog[key]!.noData;
              break;
            case Type.double:
              userData[key] =
                  double.tryParse(_controllers[key]?.text ?? "") ??
                  userDataCatalog[key]!.noData;
              break;
          }
        }
      } else if (userDataCatalog[key]!.inputMethod == InputMethod.dropdown) {
        if (_dropdownOptions.containsKey(key)) {
          userData[key] = _dropdownOptions[key] ?? userDataCatalog[key]!.noData;
        }
      }
    }
  }

  // データの保存処理
  void _save() async {
    setPageStatus(PageStatus.saving);

    updateUserDataFromDisplay();
    if (!isAllDataValid(userData, context, mounted)) {
      print('❌ 入力内容に不備があります。');
      setPageStatus(PageStatus.neutral);
      return;
    }

    try {
      await requestUpdateAPI();
      print('✅ ユーザー情報登録に成功しました: $userData');
      if (!mounted) return;
      showSnackBarMessage('保存しました。', context, mounted);
      //本体に「ユーザーデータが保存されていること」を保存する
      StorageHelper.saveString('userdata_saved', 'true');
      if (widget.isFirstLogin) {
        Navigator.pushReplacementNamed(context, '/homePage');
      }
    } catch (e) {
      print('❌ ユーザー情報登録に失敗しました: $e');
      showSnackBarMessage('保存に失敗しました。もう一度お試しください。', context, mounted);
    }

    setPageStatus(PageStatus.neutral);
  }

  // データの読み込み処理
  void _load() async {
    setPageStatus(PageStatus.loading);

    try {
      final response = await requestReadAPI();
      print('✅ ユーザーデータの読み込みに成功しました: $response');
      userData = response;
    } catch (e) {
      //データの読み取りに失敗した場合と、データが元からなかった場合が考えられる。
      print('❌ ユーザーデータの読み込みに失敗しました。またはデータが空です。: $e');
      if (!mounted) return;
      showSnackBarMessage('ユーザーデータを登録してください。', context, mounted);
      setPageStatus(PageStatus.neutral);
      return;
    }

    // 各コントローラーにデータをセット
    for (var key in userDataCatalog.keys) {
      if (userDataCatalog[key]!.inputMethod == InputMethod.text) {
        _controllers[key]?.text = userData[key]?.toString() ?? '';
      } else if (userDataCatalog[key]!.inputMethod == InputMethod.dropdown) {
        _dropdownOptions[key] = userData[key] ?? userDataCatalog[key]!.noData;
      }
    }

    setState(() {});
    setPageStatus(PageStatus.neutral);
  }

  // 各要素を表示するウィジェット
  Widget _userDataElement(String key) {
    if (userDataCatalog[key]!.inputMethod == InputMethod.dropdown) {
      return customDropdownButton(
        selectedValue: _dropdownOptions[key] ?? '未選択',
        options: userDataCatalog[key]!.dropdownOptions ?? [],
        onChanged: (value) {
          if (value != null) {
            _dropdownOptions[key] = value;
          }
        },
        label: userDataCatalog[key]!.displayName,
        icon: userDataCatalog[key]!.icon,
      );
    } else if (userDataCatalog[key]!.inputMethod == InputMethod.text) {
      return customInputTextField(
        controller: _controllers[key]!,
        label: userDataCatalog[key]!.displayName,
        icon: userDataCatalog[key]!.icon,
        keyboardType: userDataCatalog[key]!.keyboardType ?? TextInputType.text,
      );
    } else {
      return SizedBox.shrink();
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
                      customLargeBoldColoredTextArea('はじめまして。', context),
                      customLargeBoldColoredTextArea(
                        'あなたのことを教えてください！',
                        context,
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ...userDataCatalog.keys.map(_userDataElement),
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
