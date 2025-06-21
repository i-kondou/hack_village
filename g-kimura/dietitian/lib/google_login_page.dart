import 'package:dietitian/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'uploadimage.dart'; // 画像アップロードのためのインポート

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  User? _user;

  Future<void> _signInWithGoogle() async {
    try {
      // 1. Googleアカウントでサインイン
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("ユーザーによってキャンセルされました");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 2. Firebase に認証情報を渡す
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });

      // 3. ログイン後はHomePageに移動する
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));

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
        child: _user == null
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
