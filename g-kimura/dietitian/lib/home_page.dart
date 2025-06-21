import 'dart:math';
import 'package:dietitian/google_login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'recources/daily_messages.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _dailyMessage = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _setDailyMessage(_user?.uid.hashCode);
  }

  void _setDailyMessage(int? seed) {
    final now = DateTime.now();

    // 特定日メッセージ（例：29日は「肉の日」）
    if (now.day == 29) {
      _dailyMessage = daily_message_for_29th;
    } else if (now.month == 3 && now.day == 7) {
      _dailyMessage = daily_message_for_Mar_7th;
    } else {
      // 日にちをシードにして固定のランダムメッセージを出す
      final randomEngine= Random((seed ?? 1) * now.day);
      final index=randomEngine.nextInt(daily_messages.length);
      _dailyMessage = daily_messages[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName;
    final uid = _user?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('ホーム')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              displayName != null ? 'こんにちは、$displayName さん' : 'ユーザーID: $uid',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              _dailyMessage,
              style: TextStyle(fontSize: 16, color: Colors.green[700]),
              textAlign: TextAlign.center,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/googleLoginPage');
              },
              child: Text('ログアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
