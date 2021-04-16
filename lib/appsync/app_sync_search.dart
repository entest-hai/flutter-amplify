import 'package:flutter/material.dart';

class AppSyncSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppSyncSearchView(),
    );
  }
}

class AppSyncSearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: DataSearch());
          }, icon: Icon(Icons.search)),
        ],
      ),
      drawer: Drawer(),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(onPressed: (){
        query = "";
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
    return Center(child: Container(
      width: 100,
      height: 100,
      color: Colors.purple,
    ),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> datasets = ["NUH", "STG", "SGH", "MONASH", "SYDNEY", "MANCHESTER", "EXTLONG", "SYNTHESIED", "NAMIC"];
    List<String> suggestions = query.isEmpty ? datasets : datasets.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index){
        return ListTile(
          onTap: (){
            showResults(context);
          },
          leading: Icon(Icons.image_aspect_ratio),
          title: Text(suggestions[index]),
        );
      },
    );
  }
  
}