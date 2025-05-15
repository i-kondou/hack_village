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

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera); // または gallery

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");

      try {
        await imageRef.putFile(_image!);
        final downloadUrl = await imageRef.getDownloadURL();

        setState(() {
          _uploadedImageUrl = downloadUrl;
        });

        print("✅ アップロード完了: $downloadUrl");
        analyzeImage(downloadUrl); // 画像分析関数を呼び出す
      } catch (e) {
        print("❌ アップロード失敗: $e");
      }
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
            _image != null ? Image.file(_image!, height: 200) : Text("画像なし"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text("画像を撮影してアップロード"),
            ),
            if (_uploadedImageUrl != null)
              SelectableText("アップロード先URL:\n$_uploadedImageUrl"),
          ],
        ),
      ),
    );
  }
}
