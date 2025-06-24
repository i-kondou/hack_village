import 'package:flutter/material.dart';

void showSnackBarMessage(String message, BuildContext context, bool mounted) {
  if (!mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(message), duration: Duration(seconds: 2)),
  );
}
