import 'package:firebase_auth/firebase_auth.dart';

// トークン取ってくる用のメソッド、関係ないのでお気になさらず
void loadIdToken() async {
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token != null) {
    debugPrint('token: $token');
  }
}

void debugPrint(String text) {
  const chunkSize = 800; // 1回に表示する文字数（安全圏）
  for (var i = 0; i < text.length; i += chunkSize) {
    final endIndex =
        (i + chunkSize < text.length) ? i + chunkSize : text.length;
    print(text.substring(i, endIndex));
  }
}
