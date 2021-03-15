import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

// API URL
final sqiApiBaseUrl =
    "https://bln9cf30wj.execute-api.ap-southeast-1.amazonaws.com/default/pythontest?filename=s3://flutteramplify32917a364a1942d5b5203a9c772381ec102628-dev/public/";

//  SQI Data Modal
class SQI {
  final int pass;
  final String recordname;
  final double mSQICh1;
  final double mSQICh2;
  final double mSQICh3;
  final double mSQICh4;
  final double fSQICh1;
  final double fSQICh2;
  final double fSQICh3;
  final double fSQICh4;
  final int invertCh1;
  final int invertCh2;
  final int invertCh3;
  final int invertCh4;
  final String summary;

  SQI(
      {this.pass,
      this.recordname,
      this.mSQICh1,
      this.mSQICh2,
      this.mSQICh3,
      this.mSQICh4,
      this.fSQICh1,
      this.fSQICh2,
      this.fSQICh3,
      this.fSQICh4,
      this.invertCh1,
      this.invertCh2,
      this.invertCh3,
      this.invertCh4,
      this.summary});

  factory SQI.fromJson(Map<String, dynamic> json) {
    final recordname = json['recordname'];
    final summary = "recordname: " +
        json['recordname'] +
        "\n" +
        "pass: " +
        (json['pass'] as int).toString() +
        "\n" +
        "mSQICh1: " +
        (json['mSQI_ch1'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh2: " +
        (json['mSQI_ch2'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh3: " +
        (json['mSQI_ch3'] as double).toStringAsFixed(3) +
        "\n" +
        "mSQICh4: " +
        (json['mSQI_ch4'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh1: " +
        (json['fSQI_ch1'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh1: " +
        (json['fSQI_ch2'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh2: " +
        (json['fSQI_ch3'] as double).toStringAsFixed(3) +
        "\n" +
        "fSQICh3: " +
        (json['fSQI_ch4'] as double).toStringAsFixed(3) +
        "\n" +
        "invertedCh1: " +
        (json["Inverted_ch1"] as int).toString() +
        "\n" +
        "invertedCh2: " +
        (json["Inverted_ch2"] as int).toString() +
        "\n" +
        "invertedCh3: " +
        (json["Inverted_ch3"] as int).toString() +
        "\n" +
        "invertedCh4: " +
        (json["Inverted_ch4"] as int).toString();

    return SQI(
        pass: json['pass'],
        recordname: recordname,
        mSQICh1: json['mSQI_ch1'],
        mSQICh2: json['mSQI_ch2'],
        mSQICh3: json['mSQI_ch3'],
        mSQICh4: json['mSQI_ch4'],
        fSQICh1: json['fSQI_ch1'],
        fSQICh2: json['fSQI_ch2'],
        fSQICh3: json['fSQI_ch3'],
        fSQICh4: json['fSQI_ch4'],
        invertCh1: json['Inverted_ch1'],
        invertCh2: json['Inverted_ch2'],
        invertCh3: json['Inverted_ch3'],
        invertCh4: json['Inverted_ch4'],
        summary: summary);
  }
}

// CTG Repository
class CTGRepository {
  Future<GetUrlResult> getCTG(StorageItem item) async {
    try {
      GetUrlResult url = await Amplify.Storage.getUrl(key: item.key);
      return url;
    } on StorageException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<SQI> computeSQI(StorageItem item) async {
    final url = sqiApiBaseUrl + item.key.toString();
    final response = await http.get(url);
    final json = jsonDecode(response.body);
    return SQI.fromJson(json);
  }
}

// Data Repository
class DataRepository {
  void uploadFile() async {
    Map<String, String> metadata = <String, String>{};
    metadata['name'] = 'rawecg.csv';
    metadata['desc'] = 'a test file';
    S3UploadFileOptions options = S3UploadFileOptions(
        accessLevel: StorageAccessLevel.guest, metadata: metadata);
    final key = new DateTime.now().toString();
    // Pick a file
    FilePickerResult result = await FilePicker.platform.pickFiles();
    // Try to upload to S3
    if (result != null) {
      File file = File(result.files.single.path);
      try {
        UploadFileResult uploadResult = await Amplify.Storage.uploadFile(
            local: file,
            key: key + file.path.split("/").last,
            options: options);
        print("file: ${file.path} ${uploadResult.toString()}");
      } on StorageException catch (e) {
        print(e.message);
      }
    } else {}
  }

  Future<List<StorageItem>> listFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      List<StorageItem> items = res.items
          .where((element) => element.key.toString().isNotEmpty)
          .toList();
      return items;
    } on StorageException catch (e) {
      print(e.message);
      return null;
    }
  }
}
