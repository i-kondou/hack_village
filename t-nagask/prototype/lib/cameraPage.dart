// ***************************************************
// カメラページを表示するためのウィジェット
//
// ***************************************************

import 'package:prototype/main.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// カメラ関連
import 'package:camera/camera.dart';

// Firebase 関連
import 'package:firebase_storage/firebase_storage.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.title});
  final String title;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  Future<void>? initializeControllerFuture;

  // ***************************************************
  // カメラを利用するためのメソッド呼び出しを追加
  @override
  void initState() {
    super.initState();
    initCamera();
  }

  // ***************************************************
  // カメラ選択
  // TODO: カメラ選択を実装する
  Future<void> initCamera() async {
    try {
      final backCamera = globalCameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      controller = CameraController(backCamera, ResolutionPreset.medium);
      initializeControllerFuture = controller!.initialize();
      await initializeControllerFuture;
      setState(() {}); // 初期化後にUIを更新
    } catch (e) {
      debugPrint('カメラ初期化失敗: $e');
    }
  }

  // ***************************************************
  // カメラの使用を終了してリソース解放、必須
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // ***************************************************
  // Firebase Storageに画像を保存するメソッド
  Future<void> uploadImage(String imagePath) async {
    try {
      File file = File(imagePath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child(
        'images/$fileName',
      );
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('画像アップロード完了: $downloadUrl');
    } catch (e) {
      debugPrint('画像アップロード失敗: $e');
    }
  }

  // ***************************************************
  // 撮影用メソッド
  void shoot() async {
    try {
      await initializeControllerFuture;
      final image = await controller!.takePicture();
      debugPrint('撮影完了: ${image.path}');
      await uploadImage(image.path);
    } catch (e) {
      debugPrint('撮影失敗: $e');
    }
  }

  // ***************************************************
  // UIのビルド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:
          (initializeControllerFuture == null)
              // カメラの初期化が完了していない場合はローディングインジケーターを表示
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<void>(
                future: initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      controller != null) {
                    return CameraPreview(controller!);
                  } else if (snapshot.hasError) {
                    return Center(child: Text('カメラエラー: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
      // FloatingActionButtonを追加して、カメラで写真を撮影する
      floatingActionButton: FloatingActionButton(
        onPressed: shoot,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
