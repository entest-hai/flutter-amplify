import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Amplify
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter_amplify/amplifyconfiguration.dart';
// AppSync Cubit and State
import 'appsync_cubit.dart';
import 'appsync_state.dart';
import 'appsync_ctg_model.dart';
// AppSync Item Cubit and State
import 'appsync_item_cubit.dart';
import 'appsync_item_state.dart';
import 'package:photo_view/photo_view.dart';

class AppSyncApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AppSyncCTGCubit()),
          BlocProvider(create: (context) => AppSyncItemCubit()),
        ],
        child: AppSyncNav(),
      ),
    );
  }
}

class AppSyncNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(child: AppSyncListView())
      ],
      onPopPage: (result, route){
        route.didPop(result);
      },
    );
  }
}

class AppSyncListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppSyncState();
  }
}

class _AppSyncState extends State<AppSyncListView> {

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
        title: Text("AppSync"),
        actions: [
          ElevatedButton(onPressed: (){
            BlocProvider.of<AppSyncCTGCubit>(context).fetchCTG();
          }, child: Icon(Icons.download_sharp))
        ],
      ),
      body: BlocBuilder<AppSyncCTGCubit, AppSyncCTGState>(builder: (context, state){

        if (state.isFetchSuccess) {
          return ListView.builder(
            itemCount: state.ctgs.length,
            itemBuilder: (context, index){
              return _buildCTGCard(state.ctgs[index]);
            },
          );
        } else if (state.isFetching){
          return Center(child: CircularProgressIndicator(),);
        } else {
          return Center(child: Text("Click To Load Data"),);
        }
      },),
    );
  }

  Card _buildCTGCard(CTGRecordModel ctg){
    return Card(
      child: ListTile(
        leading: Icon(Icons.image, color: Colors.purple,),
        title: Text("${ctg.ctgUrl} ${ctg.createdAt}"),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AppSyncFileDetailView(
            ctg: ctg,
          )));;
        },
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
}

class AppSyncFileDetailView extends StatefulWidget {
  final CTGRecordModel ctg;
  AppSyncFileDetailView({this.ctg});

  @override
  State<StatefulWidget> createState() {
    return _AppSyncFileState();
  }
}

class _AppSyncFileState extends State<AppSyncFileDetailView> {

  @override
  void initState() {
    super.initState();

    BlocProvider.of<AppSyncItemCubit>(context).fetchCtgUrl(widget.ctg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail"),),
      body: SafeArea(
        child: BlocBuilder<AppSyncItemCubit, AppSyncItemState>(builder: (context, state){
          return Center(
            child: state.ctgUrl != null ?  PhotoView(imageProvider: NetworkImage(state.ctgUrl),) : CircularProgressIndicator(),
          );
        },),
      ),
    );
  }
}