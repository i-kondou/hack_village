import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>?> analyzeImage(String imageUrl) async {
  final uri = Uri.parse(
    'https://dietitian-backend--feat-919605860399.us-central1.run.app/',
  );
  final dio = Dio(BaseOptions(baseUrl: uri.toString()));

  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  final resp = await dio.post(
    '/meal/upload',
    queryParameters: {'image_url': imageUrl},
    options: Options(
      contentType: 'application/json',
      headers: {"Authorization": 'Bearer ${token ?? ''}'},
    ),
    onSendProgress:
        (sent, total) =>
            print('upload ${(sent / total * 100).toStringAsFixed(1)} %'),
  );

  final response = resp.data;

  if (response is Map<String, dynamic> && response.containsKey('error')) {
    print('エラー: ${response['error']}');
    return null;
  }
  if (response is Map<String, dynamic> && response.containsKey('result')) {
    return response['result'] as Map<String, dynamic>;
  }

  return resp.data;
}
