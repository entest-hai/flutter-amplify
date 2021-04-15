import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'dart:convert';
import 'appsync_ctg_model.dart';

class AppSyncRepository {
  Future<List<CTGRecordModel>> fetchCTGs() async {
    List<CTGRecordModel> records = [];

    try {
      String graphQLDocument = '''query listCTGs {
      listCTGs(limit : 100) {
        items {
          ctgUrl
          username
          fHR
          mHR
          decelsDuration
          acelsDuration
          acelsTime
          decelsTime
          ecgUrl
          id
          stv
          userId
          baseline
          basvar
          createdAt
        }
      }
    }''';

    var operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: graphQLDocument,
        ));

    var response = await operation.response;
    var items = jsonDecode(response.data.toString())['listCTGs']['items'];
    print(items.length);
    for (var item in items) {
      records.add(
        CTGRecordModel.fromJson(item)
      );

    }
  } on ApiException catch (e) {
    print('Query failed: $e');
  }

    return records;
  }

}