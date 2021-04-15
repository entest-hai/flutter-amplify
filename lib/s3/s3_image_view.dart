import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter_amplify/amplifyconfiguration.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
class S3PhotoViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: S3PhotoView(),
    );
  }
}

class S3PhotoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _S3PhotoState();
  }
}

class _S3PhotoState extends State<S3PhotoView> {
  bool isFetching = false;
  final storageItem = StorageItem(key: "ctg/104.csv.png");
  String imageUrl = "";

  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo"),
        actions: [
          ElevatedButton(onPressed: (){
            getImageUrl(StorageItem(key: "ctg/1004.csv.png"));
          }, child: Icon(Icons.download_sharp)),
        ],
      ),
      body: Center(
        child: isFetching ? CircularProgressIndicator() : Container(
          child: PhotoView(imageProvider: imageUrl != "" ? NetworkImage(imageUrl) : AssetImage("assets/images/whale.jpeg"),
          ),
        ),
      ),
    );
  }

  void getImageUrl(StorageItem item) async {
    setState(() {
      isFetching = true;
    });
    GetUrlResult url =  await Amplify.Storage.getUrl(key: item.key);
    setState(() {
      imageUrl = url.url;
      isFetching = false;
    });
  }

  void _configureAmplify() async {
    if(!mounted) return;
    try {
      Amplify.addPlugins([
        AmplifyAuthCognito(), AmplifyStorageS3(), AmplifyAPI()
      ]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }

}