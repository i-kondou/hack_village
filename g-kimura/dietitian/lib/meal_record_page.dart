import 'package:flutter/material.dart';
import 'storage_helper.dart'; // loadDataが定義されているファイルをインポート

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}

class MealRecordPageState extends State<MealRecordPage> {
  late Future<List<Map<String, String>>> _mealDataListFuture;

  @override
  void initState() {
    super.initState();
    _mealDataListFuture = _loadMealDataList();
  }

  Future<List<Map<String, String>>> _loadMealDataList() async {
    final value = await StorageHelper.loadString('meal_number', '0');
    final mealNumber = int.parse(value ?? '0');
    print("✅ 食事番号: $mealNumber");
    List<Map<String, String>> mealDataList = [];
    for (var i = 1; i < mealNumber; i++) {
      final data = await StorageHelper.loadMap("analysis_result_$i");
      if (data != null) {
        print("✅ 食事 $i のデータ: $data");
        mealDataList.add(data);
      } else {
        print("❌ 食事 $i のデータは見つかりません");
      }
    }
    return mealDataList;
  }

  static Future<Map<String, String>?> loadData(String key) {
    // ここでstorage_helper.dart内のloadData関数を呼び出す
    return StorageHelper.loadMap(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('食事記録')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _mealDataListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children:
                  data
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.keys.join(', ')),
                          subtitle: Text(entry.values.join(', ')),
                        ),
                      )
                      .toList(),
            );
          } else {
            return const Center(child: Text('記録が見つかりません'));
          }
        },
      ),
    );
  }
}
