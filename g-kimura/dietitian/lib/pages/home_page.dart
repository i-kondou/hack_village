import 'dart:math';
import 'package:dietitian/utils/debug_print.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../recources/daily_messages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  User? _user;
  String _dailyMessage = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _setDailyMessage(_user?.uid.hashCode);
    loadIdToken();
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
        if (!mounted) {
          print("ページがマウントされていません");
          return;
        }
        Navigator.pushNamed(context, '/googleLoginPage');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName;
    final uid = _user?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('ホーム')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 画面幅に合わせて画像サイズを調整
            LayoutBuilder(
              builder: (context, constraints) {
                return Image.asset(
                  'assets/images/kano-eiyo.png',
                  fit: BoxFit.contain,
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              displayName != null ? 'こんにちは、$displayName さん' : 'ユーザーID: $uid',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _dailyMessage,
              style: TextStyle(fontSize: 16, color: Colors.green[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...[
              ElevatedButton(
                child: const Text('画像をアップロード'),
                onPressed: () {
                  Navigator.pushNamed(context, '/uploadImagePage');
                },
              ),
              ElevatedButton(
                child: const Text('マイ情報'),
                onPressed: () {
                  Navigator.pushNamed(context, '/myInformationPage');
                },
              ),
              ElevatedButton(
                child: const Text('食事記録'),
                onPressed: () {
                  Navigator.pushNamed(context, '/mealRecordPage');
                },
              ),
              ElevatedButton(
                onPressed: _onLogoutButtonPressed,
                child: const Text('ログアウト'),
              ),
            ].map(
              (btn) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: btn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
