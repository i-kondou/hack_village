import 'package:dietitian/recources/nutrition_facts.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await Dio().get(
      'https://dietitian-backend--feat-919605860399.us-central1.run.app/meal/list',
      options: Options(
        contentType: 'application/json',
        headers: {"Authorization": 'Bearer ${token ?? ''}'},
      ),
    );
    List<Map<String, String>> mealDataList = [];
    for (var i = 1; i < response.data['meal_records'].length; i++) {
      Map<String, dynamic> responseData = response.data['meal_records'][i];
      Map<String, String> mealData = {};
      for (var key in responseData.keys) {
        if (key != 'imageUrl') {
          mealData[key] = responseData[key].toString();
        }
        if (key == 'eatenAt') {
          // 日付を整形
          DateTime dateTime = DateTime.parse(responseData[key]);
          mealData[key] =
              '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
        }
      }
      print('mealDataList[$i]: $mealData');
      mealDataList.add(mealData);
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
                      //食事番号、カロリーなど項目名(太字)
                      Expanded(
                        flex: 3,
                        child: Text(
                          nutritionFactsLabel[e.key] ?? e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      //項目の値(通常フォント)
                      Expanded(
                        flex: 5,
                        child: Text(
                          e.value + (nutritionFactsUnits[e.key] ?? ''),
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
    if (data.isEmpty) {
      return const Center(child: Text('グラフに表示するデータがありません'));
    }

    // 表示対象とするキーを定義（ここでは数値データのみと仮定し、最初のデータから取得）
    final keys =
        data.first.keys
            .where((k) => !['advice_message', 'menu', 'eatenAt'].contains(k))
            .toList();

    // 栄養素ごとのスポットをMapに保存
    final Map<String, List<FlSpot>> nutrientSpots = {
      for (var key in keys) key: <FlSpot>[],
    };

    for (int i = 0; i < data.length; i++) {
      for (final key in keys) {
        final valueStr = data[i][key];
        final value = double.tryParse(valueStr ?? '');
        if (value != null) {
          nutrientSpots[key]?.add(FlSpot(i.toDouble(), value));
        }
      }
    }

    // 色リストを用意（栄養素数が多くても繰り返して対応）
    final colors = [
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                backgroundColor: Colors.white,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          //del
                          return Text(index.toString());
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData:
                    nutrientSpots.entries.mapIndexed((entry, i) {
                      final spots = entry.value;
                      return LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colors[i % colors.length],
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                      );
                    }).toList(),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineTouchData: LineTouchData(enabled: true),
              ),
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          children:
              nutrientSpots.keys.mapIndexed((name, i) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[i % colors.length],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${nutritionFactsLabel[name] ?? name} (${nutritionFactsUnits[name] ?? ''})',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食事記録'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.list), SizedBox(width: 8), Text('リスト')],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart),
                  SizedBox(width: 8),
                  Text('グラフ'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(decoration: backGroundBoxDecoration()),
          FutureBuilder<List<Map<String, String>>>(
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
        ],
      ),
    );
  }
}

extension MapIndexed<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    int i = 0;
    return map((e) => f(e, i++));
  }
}
