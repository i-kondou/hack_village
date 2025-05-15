import 'package:cloud_firestore/cloud_firestore.dart';
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

    try {
      await FirebaseFirestore.instance.collection('test').add({
        'timestamp': DateTime.now().toIso8601String(),
        'message': '通信確認テスト',
      });
      print('✅ Firestore に書き込み成功');
    } catch (e) {
      print('❌ Firestore 書き込み失敗: $e');
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
