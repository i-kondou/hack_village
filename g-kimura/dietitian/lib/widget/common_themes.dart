import 'package:flutter/material.dart';

BoxDecoration backGroundBoxDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.teal.shade200, Colors.teal.shade600],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
