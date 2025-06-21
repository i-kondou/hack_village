import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'analyze_image.dart';

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _uploadedImageUrl;
  Map<String, dynamic>? analysisResult;
  bool _isUploading = false;
  bool _isAnalyzing = false;

  // 画像を選択するメソッド
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        _image = File(pickedFile.path);
      });
    } catch (e) {
      print("❌ 画像選択エラー: $e");
    }
  }

  // Firebase Storageに画像をアップロードするメソッド
  Future<void> _uploadImageToFirebase() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(
      "images/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    try {
      // 画像のアップロード
      setState(() {
        _isUploading = true;
      });
      await imageRef.putFile(_image!);
      final downloadUrl = await imageRef.getDownloadURL();
      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });
      print("✅ アップロード完了: $downloadUrl");

      // 画像分析を実行
      setState(() {
        _isAnalyzing = true;
      });
      await Future.delayed(Duration(seconds: 1));
      analysisResult = await analyzeImage(downloadUrl);
      setState(() {
        _isAnalyzing = false;
      });
      print("✅ 分析結果: ${analysisResult}");
    } catch (e) {
      print("❌ アップロード失敗: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("画像アップロード")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text("画像が選択されていません"),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [SelectCameraButton(), SelectAlbumButton()],
                ),
              ],
            ),
            SizedBox(height: 20),
            UploadButton(),
            SizedBox(height: 20),
            DetailInfo(),
          ],
        ),
      ),
    );
  }

  // ====================================================
  //  ↓↓ ここから下　Widget 宣言 ↓↓

  // アップロードボタン
  Widget UploadButton() {
    return ElevatedButton.icon(
      onPressed:
          _image != null ? () async => await _uploadImageToFirebase() : null,
      icon: Icon(Icons.upload),
      label: Text("アップロード"),
      style: ElevatedButton.styleFrom(
        backgroundColor: _image != null ? null : Colors.grey,
      ),
    );
  }

  // カメラ選択ボタン
  Widget SelectCameraButton() {
    return ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: Icon(Icons.camera_alt),
      label: Text("カメラ"),
    );
  }

  // アルバム選択ボタン
  Widget SelectAlbumButton() {
    return ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.gallery),
      icon: Icon(Icons.photo),
      label: Text("アルバム"),
    );
  }

  // ローディングインジケーター
  Widget LoadingIndicator(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [CircularProgressIndicator(), Text(message)],
    );
  }

  // 詳細情報表示
  Widget DetailInfo() {
    if (_isUploading) {
      return LoadingIndicator("アップロード中...");
    } else if (_isAnalyzing) {
      return LoadingIndicator("分析中...");
    } else if (_image == null) {
      return Text("画像が選択されていません");
    } else if (_uploadedImageUrl == null) {
      return Text("画像がアップロードされていません");
    } else if (analysisResult != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // data から取り出して表示
          _buildMenuName("menu"),
          SizedBox(height: 10),
          _buildAnalysisResult("calorie", "カロリー"),
          _buildAnalysisResult("protein", "タンパク質"),
          _buildAnalysisResult("fat", "脂質"),
          _buildAnalysisResult("carbohydrate", "炭水化物"),
          _buildAnalysisResult("dietary_fiber", "食物繊維"),
          _buildAnalysisResult("vitamin", "ビタミン"),
          _buildAnalysisResult("mineral", "ミネラル"),
          _buildAnalysisResult("sodium", "ナトリウム"),
        ],
      );
    } else {
      return Text("よくわからない状況です。");
    }
  }

  // メニュー名は別
  Widget _buildMenuName(String key) {
    return Text(
      "${analysisResult![key]}",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  // 要素ごとの表示
  Widget _buildAnalysisResult(String key, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(padding: const EdgeInsets.only(left: 40.0), child: Text(name)),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 40.0),
          child:
              (analysisResult != null && analysisResult!.containsKey(key))
                  ? Text("${analysisResult![key]}")
                  : Text("データがありません"),
        ),
      ],
    );
  }
}
