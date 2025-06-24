import 'dart:math';
import 'package:dietitian/utils/debug_print.dart';
import 'package:dietitian/widget/common_themes.dart';
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
        if (!mounted) return;
        Navigator.pushNamed(context, '/googleLoginPage');
      }
    });
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
          Container(
            decoration: backGroundBoxDecoration(),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/icon1.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName != null
                        ? 'こんにちは、$displayName さん'
                        : 'ユーザーID: $uid',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dailyMessage,
                    style: TextStyle(fontSize: 16, color: Colors.yellow[100]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildCardButton(
                          Icons.image,
                          '画像アップロード',
                          '/uploadImagePage',
                        ),
                        _buildCardButton(
                          Icons.person,
                          'マイ情報',
                          '/myInformationPage',
                        ),
                        _buildCardButton(
                          Icons.restaurant,
                          '食事記録',
                          '/mealRecordPage',
                        ),
                        _buildCardButton(
                          Icons.logout,
                          'ログアウト',
                          null,
                          onTap: _onLogoutButtonPressed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton(
    IconData icon,
    String label,
    String? routeName, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pushNamed(context, routeName!),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
