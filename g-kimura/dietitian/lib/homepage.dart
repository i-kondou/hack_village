import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ホーム')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
