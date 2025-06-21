import 'dart:io';
import 'package:dietitian/image_analyze.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("分析結果:"),
          ...analysisResult!.entries.map((entry) {
            return Text("${entry.key}: ${entry.value}");
          }).toList(),
        ],
      );
    } else {
      return Text("よくわからない状況です。");
    }
  }
}
