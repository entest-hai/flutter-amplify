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

class AppSyncSearchView  extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppSyncSearchState();
  }
}

class _AppSyncSearchState extends State<AppSyncSearchView> {
  final _scrollController = ScrollController();
  final _dataSearch = DataSearch();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // _onScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: _dataSearch);
          }, icon: Icon(Icons.search)),
        ],
      ),
      drawer: Drawer(),
      body: BlocBuilder<AppSyncCTGCubit, AppSyncCTGState>(builder: (context, state){
        if (state.isFetchSuccess) {
          return Column(children: [
            Expanded(child:  ListView.builder(
              controller: _scrollController,
              itemCount: state.ctgs.length,
              itemBuilder: (context, index){
                return _buildCTGCard(state.ctgs[index]);
              },
            )
            ),
            Center(child: state.isFetchingMore ? CircularProgressIndicator() : Container(),)
          ],);
        } else if (state.isFetching){
          return Center(child: CircularProgressIndicator(),);
        } else {
          return Center(child: Text("Search To Get Data"),);
        }
      },),
    );
  }

  Card _buildCTGCard(CTGRecordModel ctg){
    return Card(
      child: ListTile(
        leading: Icon(Icons.image, color: Colors.purple,),
        title: Text("name: ${ctg.ctgUrl.split("/").last}"),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AppSyncFileDetailView(
            ctg: ctg,
          )));;
        },
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    print("$maxScroll and $currentScroll");
    if (maxScroll == currentScroll) {
      if (!BlocProvider.of<AppSyncCTGCubit>(context).state.isFetchingMore){
        print("fetch more data");
        BlocProvider.of<AppSyncCTGCubit>(context).fetchCTG(_dataSearch.query);
      }
    }
  }

}


class DataSearch extends SearchDelegate<String> {
  static bool blockQuery = false;
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(onPressed: (){
        query = "";
        // Reset AppSyncCubit
        // BlocProvider.of<AppSyncCTGCubit>(context).reset();

      }, icon: Icon(Icons.clear)),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(onPressed: (){
      close(context, null);
    }, icon: AnimatedIcon(
      icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ),);
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query != BlocProvider.of<AppSyncCTGCubit>(context).state.query){
      blockQuery = false;
    }

    if (blockQuery){
    } else {
      BlocProvider.of<AppSyncCTGCubit>(context).reset();
      BlocProvider.of<AppSyncCTGCubit>(context).fetchAllCTG(query);
      blockQuery = true;
    }

    return AppSyncListView(dataset: query,);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> datasets = ["nuh", "stg", "sgh", "monash", "SYDNEY", "MANCHESTER", "extended-long", "SYNTHESIED", "NAMIC"];
    List<String> suggestions = query.isEmpty ? datasets : datasets.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index){
        return ListTile(
          onTap: (){
            blockQuery = false;
            query = suggestions[index];
            showResults(context);
          },
          leading: Icon(Icons.image_aspect_ratio),
          title: Text(suggestions[index]),
        );
      },
    );
  }
}


class AppSyncListView extends StatefulWidget {

  final String dataset;
  AppSyncListView({this.dataset});

  @override
  State<StatefulWidget> createState() {
    return _AppSyncState();
  }
}

class _AppSyncState extends State<AppSyncListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppSyncCTGCubit, AppSyncCTGState>(builder: (context, state){
        if (state.isFetchSuccess) {
          return Column(children: [
            Expanded(child:  ListView.builder(
              controller: _scrollController,
              itemCount: state.ctgs.length,
              itemBuilder: (context, index){
                return _buildCTGCard(state.ctgs[index]);
              },
            )
            ),
            Center(child: state.isFetchingMore ? CircularProgressIndicator() : Container(),)
          ],);
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
        title: Text("name: ${ctg.ctgUrl.split("/").last} "),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AppSyncFileDetailView(
            ctg: ctg,
          )));;
        },
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll == currentScroll) {
      if (!BlocProvider.of<AppSyncCTGCubit>(context).state.isFetchingMore){
        BlocProvider.of<AppSyncCTGCubit>(context).fetchCTG(widget.dataset);
      }
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
    // BlocProvider.of<AppSyncItemCubit>(context).fetchCtgUrl(widget.ctg);
    BlocProvider.of<AppSyncItemCubit>(context).downloadCtg(widget.ctg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail"),),
      body: SafeArea(
        child: BlocBuilder<AppSyncItemCubit, AppSyncItemState>(builder: (context, state){
          if (state is AppSyncItemDownloading) {
            return Center(child:  CircularProgressIndicator(),);
          } else if (state is AppSyncItemDownloadedSuccess) {
            return Center(
              child: PhotoView(
                imageProvider: FileImage(state.localCtgPath),
              ),
              // child: state.ctgUrl != null ?  PhotoView(imageProvider: NetworkImage(state.ctgUrl),) : CircularProgressIndicator(),
            );
          };
        },),
      ),
    );
  }
}


