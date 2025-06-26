import 'package:dietitian/recources/nutrition_facts.dart';
import 'package:dietitian/widget/common_themes.dart';
import 'package:dietitian/widget/common_widgets.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MealRecordPage extends StatefulWidget {
  const MealRecordPage({super.key});

  @override
  MealRecordPageState createState() => MealRecordPageState();
}

class MealRecordPageState extends State<MealRecordPage>
    with TickerProviderStateMixin {
  List<Map<String, String>> _mealDataList = [];
  late TabController _tabController;
  PageStatus _pageStatus = PageStatus.userDataLoading;

  @override
  void initState() {
    super.initState();
    _loadMealDataList();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadMealDataList() async {
    setState(() => _pageStatus = PageStatus.userDataLoading);

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final response = await Dio().get(
        'https://dietitian-backend--feat-919605860399.us-central1.run.app/meal/list',
        options: Options(
          contentType: 'application/json',
          headers: {"Authorization": 'Bearer ${token ?? ''}'},
        ),
      );

      final data = <Map<String, String>>[];
      for (var i = 1; i < response.data['meal_records'].length; i++) {
        final record = response.data['meal_records'][i];
        final entry = <String, String>{};
        for (var key in record.keys) {
          if (key != 'imageUrl') {
            entry[key] =
                key == 'eatenAt'
                    ? DateTime.parse(
                      record[key],
                    ).toLocal().toString().substring(0, 16)
                    : record[key].toString();
          }
        }
        data.add(entry);
      }

      setState(() {
        _mealDataList = data;
        _pageStatus =
            data.isEmpty ? PageStatus.dataEmpty : PageStatus.dataLoaded;
      });
    } catch (e) {
      print("エラー: $e");
      setState(() => _pageStatus = PageStatus.error);
    }
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
                          return Text(
                            data[index]['eatenAt']!.substring(5, 10).toString(),
                            style: const TextStyle(fontSize: 12),
                          );
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
                lineTouchData: LineTouchData(enabled: false),
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
                children: [Icon(Icons.list), SizedBox(width: 8), Text('リスト')],
              ),
            ),
            Tab(
              child: Row(
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
          if (_pageStatus == PageStatus.userDataLoading)
            Center(child: customLoadingIndicator("ローディング中..."))
          else if (_pageStatus == PageStatus.error)
            const Center(child: Text('エラーが発生しました'))
          else if (_pageStatus == PageStatus.dataEmpty)
            const Center(child: Text('記録が見つかりません'))
          else
            TabBarView(
              controller: _tabController,
              children: [
                _buildListView(_mealDataList),
                _buildGraphView(_mealDataList),
              ],
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

enum PageStatus { userDataLoading, dataLoaded, dataEmpty, error }
