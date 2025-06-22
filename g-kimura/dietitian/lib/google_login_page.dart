import 'package:dietitian/home_page.dart';
import 'package:dietitian/my_information_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'storage_helper.dart';
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
      await StorageHelper.saveData(userData, 'google_auth_data');

      // 3. ユーザー登録APIにトークンを渡す
      try {
        final dio = Dio();
        final response = await dio.post(
          'https://dietitian-backend--main-919605860399.us-central1.run.app/dummy/user/register',
          data: {'id_token': googleAuth.idToken ?? ''},
          options: Options(contentType: 'application/json'),
          onSendProgress:
              (sent, total) =>
                  print('upload ${(sent / total * 100).toStringAsFixed(1)} %'),
        );
        print('✅ ユーザー登録成功');
      } catch (e) {
        print('❌ ユーザー登録失敗: $e');
      }

      // 4. Firebase に認証情報を渡す
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

<<<<<<< HEAD
      // 5. ページ移動
      // 　すでにユーザデータがある場合はホームページへ遷移
      // 　ない場合はマイ情報登録ページへ遷移
      // 　分岐未実装、とりあえずマイ情報登録ページへ遷移
      if (false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyInformationPage()),
        );
      }
=======
      // 3. ログイン後はHomePageに移動する
      if (!mounted){
        print("ページがマウントされていません");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
>>>>>>> origin/main

      print("✅ ログイン成功: ${_user?.displayName}");
    } catch (e) {
      print("❌ ログインエラー: $e");
    }
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
    });
    print("🚪 ログアウトしました");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google ログイン")),
      body: Center(
        child:
            _user == null
                ? ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: Icon(Icons.login),
                  label: Text("Googleでログイン"),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(_user!.photoURL ?? ""),
                      radius: 40,
                    ),
                    SizedBox(height: 10),
                    Text("ようこそ, ${_user!.displayName}"),
                    Text("Email: ${_user!.email}"),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: Icon(Icons.logout),
                      label: Text("ログアウト"),
                    ),
                  ],
                ),
      ),
    );
  }
}
