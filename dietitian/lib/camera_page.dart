import 'dart:typed_data';
import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Uint8List? _imageBytes;
  io.File? _imageFile; // モバイル向け
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera); // Webではfile pickerとして動作

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      } else {
        setState(() {
          _imageFile = io.File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (kIsWeb && _imageBytes != null) {
      imageWidget = Image.memory(_imageBytes!);
    } else if (!kIsWeb && _imageFile != null) {
      imageWidget = Image.file(_imageFile!);
    } else {
      imageWidget = Text('まだ画像が選ばれていません');
    }

    return Scaffold(
      appBar: AppBar(title: Text('画像を選択')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageWidget,
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('画像を選択'),
            ),
          ],
        ),
      ),
    );
  }
}
