import 'package:dietitian/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'storage_helper.dart';

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

      // 1.5. ローカルに保存
      Map<String, String> userData = {
        'accessToken': googleAuth.accessToken ?? '',
        'idToken': googleAuth.idToken ?? '',
      };
      await StorageHelper.saveData(userData, 'google_auth_data');

      // 2. Firebase に認証情報を渡す
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

      // 3. ログイン後はHomePageに移動する
      if (!mounted) {
        print("ページがマウントされていません");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      print("✅ ログイン成功: ${_user?.displayName}");
    } catch (e) {
      print("❌ ログインエラー: $e");
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
            Image.asset('assets/images/kano-eiyo.png'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _signInWithGoogle,
              icon: Icon(Icons.login),
              label: Text("Googleでログイン"),
            ),
          ],
        ),
      ),
    );
  }
}
