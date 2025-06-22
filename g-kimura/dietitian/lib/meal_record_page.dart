import 'package:flutter/material.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}
class MealRecordPageState extends State<MealRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('食事記録')),
      body: Center(
        child: Text('ここに食事記録の内容が表示されます'),
      ),
    );
  }
}