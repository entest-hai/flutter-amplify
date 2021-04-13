import 'package:flutter/material.dart';
// Amplify
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter_amplify/amplifyconfiguration.dart';
// S3 Cubit and State
import 'package:flutter_amplify/s3/s3_list_files_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 's3_list_files_cubit.dart';
import 's3_list_files_state.dart';
// Detail File Cubit and State
import 's3_detail_file_cubit.dart';
import 's3_detail_file_state.dart';

class S3App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => S3DetailFileCubit()),
          BlocProvider(create: (context) => S3ListFilesCubit(
            s3detailFileCubit: context.read<S3DetailFileCubit>()
          )..listFiles()),
        ], 
        child: S3Navigator(),
      ),
    );
  }
}


class S3Navigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: S3ListView()),
      ],
      onPopPage: (route, result) {
        route.didPop(result);
      },
    );
  }
}

class S3ListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return S3ListState();
  }
}

class S3ListState extends State<S3ListView> {
  bool _amplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("S3"), actions: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)
          ),
          onPressed: (){
          BlocProvider.of<S3ListFilesCubit>(context).listFiles();
        }, child: Icon(Icons.download_sharp)),
      ],),
      body: SafeArea(
        child: BlocBuilder<S3ListFilesCubit, S3ListFilesState>(builder: (context,state){
          if (state is S3ListingFiles){
            return Center(child: CircularProgressIndicator(),);
          } else if (state is S3ListFilesSuccess){
           return  ListView.builder(
          itemCount: state.files.length,
          itemBuilder: (context, index){
            return _buildS3FileCard(state.files[index]);
          },
        );
          } else if (state is S3ListFilesFailure){
            return Center(
              child: Text("Failed"),
            );
          } 
          
          else {
            return Center(child: Text("Exception"),);
          }
        }
        ),
      ),
    );
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
  
  Card _buildS3FileCard(StorageItem item){
    final String extension = item.key.toString().split(".").last;
    final icon = ('.jpg, .jpeg, .png').contains(extension) ? Icons.image : Icons.archive;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue,),
        title: Text("${item.key.toString()}"),
        onTap: (){
          BlocProvider.of<S3ListFilesCubit>(context).viewOneFile(item);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailFileView()));
        },
      ),
    );
  }
}

class DetailFileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail"),),
      body: Center(
        child: BlocBuilder<S3DetailFileCubit, S3DetailFileState>(builder: (context, state){
         if (state is FetchingS3DetailFileState){
           return Center(
             child: CircularProgressIndicator(),
           );
         } else if (state is FetchedS3DetailFileStateSuccess){
           return Image.network(state.s3detailFile.url.url,
             loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
               if (loadingProgress == null) return child;
               return Center(
                 child: CircularProgressIndicator(
                   value: loadingProgress.expectedTotalBytes != null ?
                   loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                       : null,
                 ),
               );
             },
           );
         } else {
           return Text("No Image");
         };
        },)
      ),
    );
  }
}




