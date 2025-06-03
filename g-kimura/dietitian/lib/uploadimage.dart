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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadImageToFirebase();
    } catch (e) {
      print("❌ 画像選択エラー: $e");
    }
  }

  Future<void> _uploadImageToFirebase() async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");

    try {
      await imageRef.putFile(_image!);
      final downloadUrl = await imageRef.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
      });

      print("✅ アップロード完了: $downloadUrl");

      await analyzeImage(downloadUrl);
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
            _image != null ? Image.file(_image!, height: 200) : Text("画像が選択されていません"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("カメラ"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.photo),
                  label: Text("アルバム"),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_uploadedImageUrl != null)
              SelectableText("アップロード先URL:\n$_uploadedImageUrl"),
          ],
        ),
      ),
    );
  }
}
