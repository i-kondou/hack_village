import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'analyze_image.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  UploadImagePageState createState() => UploadImagePageState();
}

class UploadImagePageState extends State<UploadImagePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
  Map<String, dynamic>? _analysisResult;
  UploadState _uploadState = UploadState.idle;
  String _errorMessage = "";

  // 画像を選択するメソッド
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        _image = File(pickedFile.path);
        _imageUrl = null; // URLをリセット
        _analysisResult = null; // 分析結果をリセット
        _uploadState = UploadState.imagePicked;
      });
    } catch (e) {
      print("❌ 画像の選択に失敗しました: $e");
      _errorMessage = e.toString();
      setState(() {
        _uploadState = UploadState.imagePickFailed;
      });
    }
  }

  // Firebase Storageに画像をアップロードするメソッド
  Future<void> _uploadImageToFirebase() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(
      "images/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    // 画像のアップロード
    try {
      setState(() {
        _uploadState = UploadState.uploading;
      });
      await imageRef.putFile(_image!);
      final downloadUrl = await imageRef.getDownloadURL();
      print("✅ アップロードが完了しました: $downloadUrl");
      setState(() {
        _imageUrl = downloadUrl;
        _uploadState = UploadState.uploadComplete;
      });
    } catch (e) {
      print("❌ アップロードに失敗しました: $e");
      _errorMessage = e.toString();
      setState(() {
        _uploadState = UploadState.uploadFailed;
      });
      return;
    }

    // 画像分析を実行
    try {
      setState(() {
        _uploadState = UploadState.analyzing;
      });
      await Future.delayed(Duration(seconds: 1));
      _analysisResult = await analyzeImage(_imageUrl!);
      print("✅ 分析結果: $_analysisResult");
      setState(() {
        _uploadState = UploadState.analysisComplete;
      });
    } catch (e) {
      print("❌ 画像分析に失敗しました: $e");
      _errorMessage = e.toString();
      setState(() {
        _uploadState = UploadState.analyzeFailed;
      });
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
                  children: [selectCameraButton(), selectAlbumButton()],
                ),
              ],
            ),
            SizedBox(height: 20),
            uploadButton(),
            SizedBox(height: 20),
            detailInfo(),
          ],
        ),
      ),
    );
  }

  // ====================================================
  //  ↓↓ ここから下　Widget 宣言 ↓↓

  // アップロードボタン
  Widget uploadButton() {
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
  Widget selectCameraButton() {
    return ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: Icon(Icons.camera_alt),
      label: Text("カメラ"),
    );
  }

  // アルバム選択ボタン
  Widget selectAlbumButton() {
    return ElevatedButton.icon(
      onPressed: () => _pickImage(ImageSource.gallery),
      icon: Icon(Icons.photo),
      label: Text("アルバム"),
    );
  }

  // ローディングインジケーター
  Widget loadingIndicator(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [CircularProgressIndicator(), Text(message)],
    );
  }

  // 詳細情報表示
  Widget detailInfo() {
    switch (_uploadState) {
      case UploadState.idle:
        return Text("今日食べた料理の画像を選択しましょう！");
      case UploadState.imagePicked:
        return Column(
          children: [Text("画像が選択されました。"), Text("アップロードして分析しましょう！")],
        );
      case UploadState.imagePickFailed:
        return Text("画像の選択に失敗しました。 $_errorMessage");
      case UploadState.uploading:
        return loadingIndicator("アップロード中...");
      case UploadState.uploadFailed:
        return Text("アップロードに失敗しました。 $_errorMessage");
      case UploadState.uploadComplete:
        return Column(children: [Text("アップロードに成功しました！"), Text("分析を開始します。")]);
      case UploadState.analyzing:
        return loadingIndicator("分析中...");
      case UploadState.analyzeFailed:
        return Text("分析に失敗しました。 $_errorMessage");
      case UploadState.analysisComplete:
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
    }
  }

  // メニュー名は別
  Widget _buildMenuName(String key) {
    return Text(
      "${_analysisResult![key]}",
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
              (_analysisResult != null && _analysisResult!.containsKey(key))
                  ? Text("${_analysisResult![key]}")
                  : Text("データがありません"),
        ),
      ],
    );
  }
}

// ====================================================
// 状態管理
enum UploadState {
  idle,
  imagePicked,
  imagePickFailed,
  uploading,
  uploadFailed,
  uploadComplete,
  analyzing,
  analyzeFailed,
  analysisComplete,
}
