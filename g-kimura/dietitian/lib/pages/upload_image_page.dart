import 'dart:io';
import 'package:dietitian/services/storage_helper.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/analyze_image.dart';
import '../widget/common_widgets.dart';

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
  PageStatus _pageStatus = PageStatus.idle;
  String _errorMessage = "";
  setPageStatus(PageStatus status) {
    setState(() {
      _pageStatus = status;
    });
  }

  // 画像を選択するメソッド
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;
      setState(() {
        _image = File(pickedFile.path);
        _imageUrl = null; // URLをリセット
        _analysisResult = null; // 分析結果をリセット
        _pageStatus = PageStatus.imagePicked;
      });
    } catch (e) {
      print("❌ 画像の選択に失敗しました: $e");
      _errorMessage = e.toString();
      setPageStatus(PageStatus.imagePickFailed);
    }
  }

  // 分析結果を保存するメソッド
  Future<void> saveResult(Map<String, dynamic> result) async {
    //何階目の食事か
    result['meal_number'] = await StorageHelper.loadString('meal_number', '1');
    final mealNumber = int.parse(result['meal_number']);
    // meal_numberに応じてキーを変更
    final String key = 'analysis_result_$mealNumber';
    //日付情報追加
    result.addEntries([MapEntry("date", DateTime.now().toLocal().toString())]);
    StorageHelper.saveMap(result, key);
    // 次の食事のためにmeal_numberを更新
    await StorageHelper.saveString('meal_number', (mealNumber + 1).toString());
    // 保存完了のメッセージ
    print("✅ 分析結果を保存しました: $key");
  }

  // Firebase Storageに画像をアップロードするメソッド
  Future<void> _uploadImageToFirebase() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(
      "images/${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    // 画像のアップロード
    try {
      setPageStatus(PageStatus.uploading);
      await imageRef.putFile(_image!);
      final downloadUrl = await imageRef.getDownloadURL();
      print("✅ アップロードが完了しました: $downloadUrl");
      setPageStatus(PageStatus.uploadComplete);
      _imageUrl = downloadUrl;
    } catch (e) {
      print("❌ アップロードに失敗しました: $e");
      _errorMessage = e.toString();
      setPageStatus(PageStatus.uploadFailed);
      return;
    }

    // 画像分析を実行
    try {
      setPageStatus(PageStatus.analyzing);
      await Future.delayed(Duration(seconds: 1));
      _analysisResult = await analyzeImage(_imageUrl!);
      print("✅ 分析結果: $_analysisResult");
      // 分析結果を保存
      saveResult(_analysisResult!);
      setPageStatus(PageStatus.analysisComplete);
    } catch (e) {
      print("❌ 画像分析に失敗しました: $e");
      _errorMessage = e.toString();
      setPageStatus(PageStatus.analyzeFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("画像アップロード")),
      body: Stack(
        children: [
          Container(decoration: backGroundBoxDecoration()),
          Padding(
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
        ],
      ),
    );
  }

  // ====================================================
  //  ↓↓ ここから下　Widget 宣言 ↓↓

  Widget uploadButton() {
    return customElevatedButton(
      onPressed: () async => await _uploadImageToFirebase(),
      icon: Icons.upload,
      label: "アップロード",
      isValid: _image != null,
    );
  }

  Widget selectCameraButton() {
    return customElevatedButton(
      onPressed: () => _pickImage(ImageSource.camera),
      icon: Icons.camera_alt,
      label: "カメラ",
      isValid: true,
    );
  }

  Widget selectAlbumButton() {
    return customElevatedButton(
      onPressed: () => _pickImage(ImageSource.gallery),
      icon: Icons.photo,
      label: "アルバム",
      isValid: true,
    );
  }

  Widget detailInfo() {
    switch (_pageStatus) {
      case PageStatus.idle:
        return Text("今日食べた料理の画像を選択しましょう！");
      case PageStatus.imagePicked:
        return Column(
          children: [Text("画像が選択されました。"), Text("アップロードして分析しましょう！")],
        );
      case PageStatus.imagePickFailed:
        return Text("画像の選択に失敗しました。 $_errorMessage");
      case PageStatus.uploading:
        return customLoadingIndicator("アップロード中...");
      case PageStatus.uploadFailed:
        return Text("アップロードに失敗しました。 $_errorMessage");
      case PageStatus.uploadComplete:
        return Column(children: [Text("アップロードに成功しました！"), Text("分析を開始します。")]);
      case PageStatus.analyzing:
        return customLoadingIndicator("分析中...");
      case PageStatus.analyzeFailed:
        return Text("分析に失敗しました。 $_errorMessage");
      case PageStatus.analysisComplete:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // data から取り出して表示
            _buildBoldText("menu_name"),
            _buildText("calorie", "カロリー"),
            _buildText("protein", "タンパク質"),
            _buildText("fat", "脂質"),
            _buildText("carbohydrate", "炭水化物"),
            _buildText("dietary_fiber", "食物繊維"),
            _buildText("vitamin", "ビタミン"),
            _buildText("mineral", "ミネラル"),
            _buildText("sodium", "ナトリウム"),
            _buildBoldText("advice_message"),
          ],
        );
    }
  }

  // メニュー名は別
  Widget _buildBoldText(String key) {
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
  Widget _buildText(String key, String name) {
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
// ページの状態管理
enum PageStatus {
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
