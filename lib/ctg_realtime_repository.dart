import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import 'ctg_repository.dart';

// Beat Model
class Beat {
  final int createdTime;
  final List<double> mHR;
  final List<double> fHR;
  Beat({this.createdTime, this.mHR, this.fHR});

  factory Beat.fromJson(Map<String, dynamic> json) {
    final List<double> mHR = [];
    final List<double> fHR = [];
    final createdTime = json['createdTime'] as int;
    final mBeats = json['mHR'];
    final fBeats = json['fHR'];

    for (var beat in mBeats) {
      mHR.add(double.parse('$beat'));
    }

    for (var beat in fBeats) {
      fHR.add(double.parse('$beat'));
    }

    return Beat(createdTime: createdTime, mHR: mHR, fHR: fHR);
  }
}

// Beat Repository
class BeatRepository {
  final _heartRateRepository = HeartRateRepository();
  Future<void> writeBeat(StorageItem item) async {
    // Call FHR API
    final res = await _heartRateRepository
        .getHeartRateFromAPI(StorageItem(key: item.key));

    // Parse return heart rate
    final int createdTime = DateTime.now().millisecondsSinceEpoch;

    // Write to DB
    try {
      print("write beat to db");
      String graphQLDocument = '''mutation CreateHeartRate {
      createHeartRate(input: {createdTime: $createdTime, fHR: ${res.fHR}, mHR: ${res.mHR}}) {
          createdTime
          fHR
          mHR
        }
    }''';

      var operation = Amplify.API.mutate(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      // print(response.data);
    } on ApiException catch (e) {
      print(e);
    }
  }

  Future<List<Beat>> fetchBeat() async {
    List<Beat> beats = [];

    try {
      String graphQLDocument = '''query ListHeartRates {
      listHeartRates {
        items {
          createdTime
          mHR
          fHR
        }
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      var items =
          jsonDecode(response.data.toString())['listHeartRates']['items'];
      for (var item in items) {
        beats.add(Beat.fromJson(item));
      }

      // sort beats by created time
      beats.sort((a, b) => a.createdTime.compareTo(b.createdTime));

      return beats;
    } on ApiException catch (e) {
      print('Query failed: $e');
      return null;
    }
  }
}
