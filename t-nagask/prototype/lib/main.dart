import 'package:flutter/material.dart';
import 'package:prototype/cameraPage.dart';

// カメラ関連
import 'package:camera/camera.dart';

// Firebase 関連
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// カメラのリスト
late List<CameraDescription> globalCameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // アプリ起動時にカメラを取得する
  globalCameras = await availableCameras();

  //Firebase 初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CameraPage(title: 'Prototype Camera Page'),
    );
  }
}
