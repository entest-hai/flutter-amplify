import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class S3PhotoViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: S3PhotoView(),
    );
  }
}

class S3PhotoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Photo"),),
      body: Center(
        child: Container(
          child: PhotoView(
            imageProvider: AssetImage("assets/images/1004.csv.png"),
          ),
        ),
      ),
    );
  }
}