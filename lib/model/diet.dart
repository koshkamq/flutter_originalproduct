import 'package:cloud_firestore/cloud_firestore.dart';

class WeightData {
  String postAccountId;
  String weight;
  Timestamp? date;

  WeightData({this.postAccountId = '', this.weight = '', this.date});
}
