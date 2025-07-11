import 'package:dietitian/pages/home_page.dart';
import 'package:dietitian/pages/my_information_page.dart';
import 'package:dietitian/utils/show_message.dart';
import 'package:dietitian/widget/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/storage_helper.dart';
import 'package:dio/dio.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  GoogleLoginPageState createState() => GoogleLoginPageState();
}

class GoogleLoginPageState extends State<GoogleLoginPage> {
  User? _user;

  Future<void> _signInWithGoogle() async {
    try {
      // 1. Googleアカウントでサインイン
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("ユーザーによってキャンセルされました");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2. ローカルにサインイン情報を保存
      Map<String, String> userData = {
        'accessToken': googleAuth.accessToken ?? '',
        'idToken': googleAuth.idToken ?? '',
      };
      await StorageHelper.saveMap(userData, 'google_auth_data');

      // 3. Firebase に認証情報を渡す
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      setState(() {
        _user = userCredential.user;
      });

      // 4. ユーザー登録APIにトークンを渡す
      bool isRegistered = false;
      try {
        final dio = Dio();
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        final response = await dio.post(
          'https://dietitian-backend--feat-919605860399.us-central1.run.app/user/create',
          options: Options(
            contentType: 'application/json',
            headers: {'Authorization': 'Bearer ${token ?? ''}'},
          ),
          onSendProgress:
              (sent, total) =>
                  print('upload ${(sent / total * 100).toStringAsFixed(1)} %'),
        );
        if (response.data['name'] != "") {
          isRegistered = true;
          print('ユーザー情報が存在します: ${response.data}');
        } else {
          print('ユーザー情報が存在しません: ${response.data}');
        }
        print('✅ ユーザー登録成功');
        //showSnackBarMessage('ユーザー登録に成功しました', context, mounted);
      } catch (e) {
        print('❌ ユーザー登録失敗: $e');
        //showSnackBarMessage('ユーザー登録に失敗しました', context, mounted);
        isRegistered = false;
      }

      // 5. ページ移動
      // 　すでにユーザデータがある場合はホームページへ遷移
      // 　ない場合はマイ情報登録ページへ遷移
      if (!mounted) return;
      if (isRegistered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyInformationPage(isFirstLogin: true),
          ),
        );
      }

      print("✅ ログイン成功: ${_user?.displayName}");
      showSnackBarMessage('ログインに成功しました', context, mounted);
    } catch (e) {
      print("❌ ログインエラー: $e");
      showSnackBarMessage('ログインに失敗しました: $e', context, mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dietitian")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "毎日の食事を管理し、\n健康的な食生活を送りましょう。",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Image.asset('assets/images/icon1.png', width: 100, height: 100),
            SizedBox(height: 20),
            customCardButton(
              Icons.login,
              //ボタンの大きさに余裕を持たせるため、文字列をスペースで囲む。
              '  Googleでログイン  ',
              null,
              context,
              onTap: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}
