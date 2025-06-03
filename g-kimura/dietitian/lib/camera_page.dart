import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _uploadedImageUrl;

  Future<void> _showPickOptionsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("画像を選択"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("カメラで撮影"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("フォトライブラリから選択"),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

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
    } catch (e) {
      print("❌ アップロード失敗: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("画像をアップロード")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null ? Image.file(_image!, height: 200) : Text("画像が選択されていません"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showPickOptionsDialog(context),
              child: Text("画像を選択"),
            ),
            if (_uploadedImageUrl != null)
              SelectableText("アップロード先URL:\n$_uploadedImageUrl"),
          ],
        ),
      ),
    );
  }
}
