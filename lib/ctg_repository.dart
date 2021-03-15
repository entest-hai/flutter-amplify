import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

// FHR API URL
final heartRateApiBaseUrl =
    "https://bln9cf30wj.execute-api.ap-southeast-1.amazonaws.com/default/femomfhr?filename=s3://flutteramplify32917a364a1942d5b5203a9c772381ec102628-dev/public/";

// Heart Rate Data Model
class FHRDataModal {
  final List<double> mHR;
  final List<double> fHR;
  FHRDataModal({this.mHR, this.fHR});
  factory FHRDataModal.fromJson(Map<String, dynamic> json) {
    final List<double> mHR = json['mHR'].cast<double>();
    final List<double> fHR = json['fHR'].cast<double>();
    return FHRDataModal(mHR: mHR, fHR: fHR);
  }
}

// HeartRate Repository
class HeartRateRepository {
  Future<List<double>> readHeartRateFile(String path) async {
    List<double> heartrates = [];
    try {
      final content = await rootBundle.loadString(path);
      final nums = content.split("\n").toList();
      for (var value in nums) {
        try {
          heartrates.add(double.parse(value));
        } catch (e) {
          heartrates.add(0.0);
        }
      }
      return heartrates;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<FHRDataModal> getHeartRateFromAPI(StorageItem item) async {
    try {
      final url = heartRateApiBaseUrl + item.key.toString();
      final response = await http.get(url);
      final json = jsonDecode(response.body);
      return FHRDataModal.fromJson(json);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
