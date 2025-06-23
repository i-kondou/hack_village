import 'package:flutter/material.dart';
import '../services/storage_helper.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}

class MealRecordPageState extends State<MealRecordPage>
    with TickerProviderStateMixin {
  late Future<List<Map<String, String>>> _mealDataListFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _mealDataListFuture = _loadMealDataList();
    _tabController = TabController(length: 2, vsync: this);
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

  // データをカード形式に変換するロジック
  Card _getCardOfMeal(Map<String, String> data) {
    // データをカード形式に変換するロジック
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              data.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
  }

  Widget _buildListView(List<Map<String, String>> data) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          '記録一覧',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ...data.map(_getCardOfMeal),
      ],
    );
  }

  Widget _buildGraphView(List<Map<String, String>> data) {
    // グラフ表示部分はダミー
    return Center(child: Text("📊 グラフ表示は未実装です"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食事記録'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'リスト'), Tab(text: 'グラフ')],
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _mealDataListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [_buildListView(data), _buildGraphView(data)],
            );
          } else {
            return const Center(child: Text('記録が見つかりません'));
          }
        },
      ),
    );
  }
}
