import 'package:dietitian/pages/google_login_page.dart';
import 'package:dietitian/pages/meal_record_page.dart';
import 'package:dietitian/pages/upload_image_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/my_information_page.dart';

void main() async {
  print("main() start");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietitian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //初回起動時(ログインしていない場合)はログイン画面を出す
      home:
          FirebaseAuth.instance.currentUser != null
              ? HomePage()
              : GoogleLoginPage(),
      routes: {
        '/homePage': (context) => HomePage(), // ホーム画面
        '/googleLoginPage': (context) => GoogleLoginPage(), // Googleログイン画面
        '/uploadImagePage': (context) => UploadImagePage(), // 画像をアップロードする画面
        '/myInformationPage': (context) => MyInformationPage(), // マイ情報の画面
        '/mealRecordPage': (context) => MealRecordPage(), // 食事記録の画面
      },
    );
  }
}
