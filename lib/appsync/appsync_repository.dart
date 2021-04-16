import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';
import 'appsync_ctg_model.dart';


class AppSyncRepository {
  List<CTGRecordModel> records;
  AppSyncRepository({this.records});
  bool isEndItem = false;
  String nextToken;
  int maxNumQueryPerLoading = 10;

  String graphQLDocumentInit = '''query listCTGs {
      listCTGs(limit : 100, nextToken: null, filter: {ecgUrl: {contains: ""}}) {
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
        },
        nextToken
      }
    }''';


  Future<void> reset(){
    this.records.clear();
    this.isEndItem = false;
    this.nextToken = null;
    this.maxNumQueryPerLoading = 10;
  }

  Future<String> singleQuery(String dataset, String nextToken) async {
    String graphQLDocument = this.graphQLDocumentInit;
    if ((nextToken == null) & (dataset != null) & (dataset != "")){
      graphQLDocument = '''query listCTGs {
        listCTGs(limit : 100, nextToken: null, filter: {ecgUrl: {contains: "$dataset"}}) {
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
          },
          nextToken
        }
      }''';
    }

    if ((nextToken != null) & (dataset != null) & (dataset != "")){
       graphQLDocument = '''query listCTGs {
        listCTGs(limit : 100, nextToken: "$nextToken", filter: {ecgUrl: {contains: "$dataset"}}) {
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
          },
          nextToken
        }
      }''';
    }
    try {
      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: graphQLDocument,
          ));
      var response = await operation.response;
      var json = jsonDecode(response.data.toString())['listCTGs'];
      var items = json['items'];
      nextToken = json['nextToken'];
      for (var item in items) {
        records.add(
            CTGRecordModel.fromJson(item)
        );
      }
      return nextToken;
    } on ApiException catch (e) {
      print('Query failed: $e');
      return null;
    }
  }


  Future<List<CTGRecordModel>> fetchCTGs(String dataset) async {
    records = [];
    String nextToken;
    nextToken = await singleQuery(dataset, null);
    print(nextToken);
    // Next query
    for (var count = 0; count < this.maxNumQueryPerLoading; count++){
      if (nextToken == null){
        break;
      }
      nextToken =  await singleQuery(dataset, nextToken);
    }
    print(records.length);
    return records;
  }

  Future<List<CTGRecordModel>> getCTGs(String dataset) async {
    if (isEndItem){
      print("reach end item in DB");
      return records;
    } else {


      this.nextToken = await singleQuery(dataset, this.nextToken);

      if (this.nextToken == null) {
        isEndItem = true;
      }

      print(records.length);
      return records;
    }
  }
}