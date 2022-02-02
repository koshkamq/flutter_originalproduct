import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class DietPage extends StatefulWidget {
  const DietPage({Key? key}) : super(key: key);

  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  var _date = DateTime.now();
  //日付選択の処理
  void onPressedRaisedButton() async {
    final DateTime? picked = await showDatePicker(
        locale: const Locale("ja"),
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2018),
        lastDate: new DateTime.now().add(new Duration(days: 360)));

    if (picked != null) {
      // 日時反映
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('折れ線グラフだお'),
            Container(
              height: 400,
              //グラフ表示部分
              child: charts.TimeSeriesChart(
                _createWeightData(weightList),
              ),
            ),
            Container(
                padding: const EdgeInsets.all(70.0),
                child: Column(
                  children: <Widget>[
                    // 日時表示部分
                    Center(child: Text("${_date}")),
                    // DatePicker表示ボタン。
                    new IconButton(
                      onPressed: () => onPressedRaisedButton(),
                      icon: Icon(Icons.date_range),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

///日付と体重を持つクラスを作成
class WeightData {
  final DateTime date;
  final double weight;

  WeightData(this.date, this.weight);
}

//WeightDataのリストを作成。好きな日付と体重入れよう
final weightList = <WeightData>[
  WeightData(DateTime(2020, 10, 2), 50),
  WeightData(DateTime(2020, 10, 3), 53),
  WeightData(DateTime(2020, 10, 4), 40)
];

//上のリストからグラフに表示させるデータを生成
List<charts.Series<WeightData, DateTime>> _createWeightData(
    List<WeightData> weightList) {
  return [
    charts.Series<WeightData, DateTime>(
      id: 'Muscles',
      data: weightList,
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (WeightData weightData, _) => weightData.date,
      measureFn: (WeightData weightData, _) => weightData.weight,
    )
  ];
}
