import 'package:flutter/material.dart';
// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
// Generated in previous step 
import 'amplifyconfiguration.dart'; 
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override 
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _amplifyConfigured = false; 

  @override
  initState() {
    super.initState(); 
    _configureAmplify(); 
  }

  @override 
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: _amplifyConfigured ? TodoView() : LoadingView(),
    );
  }

  void _configureAmplify() async {
    if (!mounted) return;
    try {
      Amplify.addPlugins([ AmplifyAuthCognito(), AmplifyStorageS3()]);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _amplifyConfigured = true;
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class TodoView extends StatefulWidget {
  @override 
  State<StatefulWidget> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  List<String> files = [];

  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
    listFiles();
  }


  @override 
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Todo"),),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(files[index]),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: 
                  Row(
                    children: [
                    IconButton(icon: Icon(Icons.cloud_download), onPressed: (){}),
                    IconButton(icon: Icon(Icons.delete), onPressed: (){})
                  ],),
                )
              ],
            ),
          );
        },
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cloud_upload), onPressed: () {
        print("upload file to s3");
        uploadFile();
      },),
    );
  }

   void uploadFile() async {
     Map<String, String> metadata = <String, String>{};
     metadata['name'] = 'rawecg.csv';
     metadata['desc'] = 'a test file';
     S3UploadFileOptions options = S3UploadFileOptions(accessLevel: StorageAccessLevel.guest, metadata: metadata);
     final key = new DateTime.now().toString() + ".csv";

     // Pick a file 
     FilePickerResult result = await FilePicker.platform.pickFiles();

     // Try to upload to S3 
     if (result != null) {
       File file = File(result.files.single.path);
       try {
         UploadFileResult uploadResult = await Amplify.Storage.uploadFile(
          local: file,
          key: key,
          options: options);
          listFiles();
          print("file: ${file.path} ${uploadResult.toString()}");
       } 
       on StorageException catch (e) {
         print(e.message);
       } 
     } else {

     }
   }

  void listFiles() async {
    try {
      ListResult res = await Amplify.Storage.list();
      List<String> items = res.items.map((e) => e.key.toString()).toList();
      print(items);
      setState(() {
        files = items;
      });
    } catch(e) {
      print(e);
    }
  }

}

class LoadingView extends StatelessWidget {
  @override
   Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Center(child: CircularProgressIndicator(),),
    );
  }
}