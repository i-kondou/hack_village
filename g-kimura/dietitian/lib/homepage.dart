import 'package:dietitian/google_login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName;
    final uid = _user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('ホーム'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayName != null
                  ? 'こんにちは、$displayName さん'
                  : 'ユーザーID: $uid',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('画像をアップロード'),
              onPressed: () {
                Navigator.pushNamed(context, '/uploadImagePage');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('マイ情報'),
              onPressed: () {
                Navigator.pushNamed(context, '/myInformationPage');
              },
            ),
            SizedBox(height:40),
            ElevatedButton(onPressed: () async {
              await GoogleSignIn().signOut();
              await FirebaseAuth.instance.signOut();
            }, child: Text('ログアウト'))
          ],
        ),
      ),
    );
  }
}
