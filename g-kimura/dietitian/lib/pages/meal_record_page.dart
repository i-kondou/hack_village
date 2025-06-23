import 'package:flutter/material.dart';
import '../services/storage_helper.dart'; // loadDataが定義されているファイルをインポート

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
              children: [
                const Text(
                  '記録一覧',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...data.map((entry) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            entry.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        e.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          } else {
            return const Center(child: Text('記録が見つかりません'));
          }
        },
      ),
    );
  }
}
