import 'dart:math';
import 'package:dietitian/services/storage_helper.dart';
import 'package:dietitian/utils/debug_print.dart';
import 'package:dietitian/utils/is_all_data_valid.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../recources/daily_messages.dart';
import '../widget/common_widgets.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  User? _user;
  String _dailyMessage = '';
  PageStatus _pageStatus = PageStatus.userDataLoading;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _setDailyMessage(_user?.uid.hashCode);
    loadIdToken();
    _checkUserData();
  }

  void _setDailyMessage(int? seed) {
    final now = DateTime.now();

    // 特定日メッセージ（例：29日は「肉の日」）
    if (now.day == 29) {
      _dailyMessage = dailyMessageFor29th;
    } else if (now.month == 3 && now.day == 7) {
      _dailyMessage = dailyMessageForMar7th;
    } else {
      // 日にちをシードにして固定のランダムメッセージを出す
      final randomEngine = Random((seed ?? 1) * now.day);
      final index = randomEngine.nextInt(dailyMessages.length);
      _dailyMessage = dailyMessages[index];
    }
  }

  Future<void> _onLogoutButtonPressed() async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ログアウト確認'),
            content: Text('本当にログアウトしますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('ログアウト'),
              ),
            ],
          ),
    ).then((shouldLogout) async {
      if (shouldLogout == true) {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        StorageHelper.saveString('userdata_saved', 'false');
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/googleLoginPage',
          (Route<dynamic> route) => false,
        );
      }
    });
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

  Future<void> _checkUserData() async {
    // ユーザーデータが保存されていない場合、マイ情報ページへ遷移
    // そもそもAPI失敗した場合はログインページへ遷移
    try {
      final userData = await requestReadAPI();
      if (!mounted) return;
      if (!isAllDataValid(userData, context, mounted)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(
            context,
            '/myInformationPageFirstLogin',
            arguments: true,
          );
        });
      } else {
        print('ユーザーデータ:保存済みです。');
        setState(() {
          _pageStatus = PageStatus.userDataLoaded;
        });
      }
    } catch (e) {
      print('ユーザーデータの取得に失敗: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, '/googleLoginPage', arguments: true);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName;
    final uid = _user?.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('ホーム', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(decoration: backGroundBoxDecoration()),
          SafeArea(
            child:
                _pageStatus == PageStatus.userDataLoading
                    ? Center(child: customLoadingIndicator("ローディング中..."))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                              'assets/images/icon1.png',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName != null
                                ? 'こんにちは、$displayName さん'
                                : 'ユーザーID: $uid',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _dailyMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.yellow[100],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          GridView.extent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              customCardButton(
                                Icons.image,
                                '画像アップロード',
                                '/uploadImagePage',
                                context,
                              ),
                              customCardButton(
                                Icons.person,
                                'マイ情報',
                                '/myInformationPage',
                                context,
                              ),
                              customCardButton(
                                Icons.restaurant,
                                '食事記録',
                                '/mealRecordPage',
                                context,
                              ),
                              customCardButton(
                                Icons.logout,
                                'ログアウト',
                                null,
                                context,
                                onTap: _onLogoutButtonPressed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

enum PageStatus { userDataLoading, userDataLoaded }
