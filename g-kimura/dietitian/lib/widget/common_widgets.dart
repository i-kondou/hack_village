import "package:flutter/material.dart";

// ローディングインジケーター
Widget loadingIndicator(String message) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 100.0),
        child: CircularProgressIndicator(),
      ),
      SizedBox(width: 10), // スペースを空けるためのウィジェット
      Padding(
        padding: const EdgeInsets.only(right: 100.0),
        child: Text(message),
      ),
    ],
  );
}

Widget largeBoldColoredText(String text, BuildContext context) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).primaryColor,
    ),
  );
}
