import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> analyzeImage(String imageUrl) async {
  //final uri = Uri.parse('https://[your-region]-[your-project-id].cloudfunctions.net/analyzeImage');
  final uri = Uri.parse(
    'https://us-central1-dietitian-a0650.cloudfunctions.net/analyzeImage',
  );

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'imageUrl': imageUrl}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("✅ ラベル分析結果: ${data['labels']}");
    return data;
  } else {
    print("❌ エラー: ${response.statusCode}");
    print(response.body);
    return null;
  }
}
