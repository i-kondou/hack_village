import 'package:flutter/material.dart';
import 'storage_helper.dart'; // loadDataが定義されているファイルをインポート

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}

class MealRecordPageState extends State<MealRecordPage> {
  late Future<Map<String, String>?> _mealDataFuture;

  @override
  void initState() {
    super.initState();
    // キーは必要に応じて変更してください
    _mealDataFuture = MealRecordPageState.loadData("analysis_result");
  }

  static Future<Map<String, String>?> loadData(String key) {
    // ここでstorage_helper.dart内のloadData関数を呼び出す
    return StorageHelper.loadData(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('食事記録')),
      body: FutureBuilder<Map<String, String>?>(
        future: _mealDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: data.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(entry.value),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text('記録が見つかりません'));
          }
        },
      ),
    );
  }
}
