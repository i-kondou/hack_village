import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';


class UploadTestPage extends StatelessWidget {
  Future<void> uploadString() async {
    final storageRef = FirebaseStorage.instance.ref();
    final testFileRef = storageRef.child('test.txt');

    // 文字列を Uint8List に変換
    String text = "Hello, Firebase!";
    Uint8List data = Uint8List.fromList(text.codeUnits);

    try {
      await testFileRef.putData(data);
      print('✅ アップロード成功！');
    } catch (e) {
      print('❌ アップロード失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Storage テスト')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadString,
          child: Text('文字列をアップロード'),
        ),
      ),
    );
  }
}
