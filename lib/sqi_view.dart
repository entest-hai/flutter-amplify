import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sqi_cubit.dart';

class TodoView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TodoViewState();
}

//
class SQIAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        if (state is ListFilesSuccess) {
          return state.files.isEmpty
              ? _emptyView()
              : Column(
                  children: [
                    Expanded(child: _listFileView(state)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          color: Colors.blue,
                          icon: Icon(
                            Icons.cloud_upload,
                            size: 50,
                          ),
                          onPressed: () {
                            BlocProvider.of<UploadCubit>(context).uploadFile();
                          }),
                    ),
                  ],
                );
        } else if (state is ListFilesFailure) {
          return _exceptionView();
        } else {
          return ListingView();
        }
      },
    );
  }

  ListView _listFileView(ListFilesSuccess state) {
    return ListView.builder(
      itemCount: state.files.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () => {
              BlocProvider.of<CTGCubit>(context).getCTG(state.files[index]),
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return CTGDetailView();
                  }).whenComplete(() {
                BlocProvider.of<CTGCubit>(context).popToDataList();
              })
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      _getFileIcon(state.files[index].key.toString()),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(state.files[index].key.toString()),
                      ))
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      IconButton(
                          icon: Icon(Icons.cloud_download), onPressed: () {}),
                      IconButton(icon: Icon(Icons.delete), onPressed: () {})
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getFileIcon(String name) {
    String extension = '.' + name.split(".").last;

    if ('.jpg, .jpeg, .png'.contains(extension)) {
      return Icon(
        Icons.image,
        color: Colors.blue,
      );
    }
    return Icon(Icons.archive);
  }

  Widget _emptyView() {
    return Center(
      child: Text("Not File Yet"),
    );
  }

  Widget _exceptionView() {
    return Center(
      child: Text("Exception"),
    );
  }
}

class _TodoViewState extends State<TodoView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("S3Upload"),
      ),
      body: BlocBuilder<UploadCubit, UploadState>(
        builder: (context, state) {
          if (state is ListFilesSuccess) {
            return state.files.isEmpty
                ? _emptyView()
                : ListView.builder(
                    itemCount: state.files.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () => {
                            BlocProvider.of<CTGCubit>(context)
                                .getCTG(state.files[index]),
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return CTGDetailView();
                                }).whenComplete(() {
                              BlocProvider.of<CTGCubit>(context)
                                  .popToDataList();
                            })
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    _getFileIcon(
                                        state.files[index].key.toString()),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                          state.files[index].key.toString()),
                                    ))
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.cloud_download),
                                        onPressed: () {}),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {})
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
          } else if (state is ListFilesFailure) {
            return _exceptionView();
          } else {
            return ListingView();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cloud_upload),
        onPressed: () {
          BlocProvider.of<UploadCubit>(context).uploadFile();
        },
      ),
    );
  }

  Widget _getFileIcon(String name) {
    String extension = '.' + name.split(".").last;

    if ('.jpg, .jpeg, .png'.contains(extension)) {
      return Icon(
        Icons.image,
        color: Colors.blue,
      );
    }
    return Icon(Icons.archive);
  }

  Widget _emptyView() {
    return Center(
      child: Text("Not File Yet"),
    );
  }

  Widget _exceptionView() {
    return Center(
      child: Text("Exception"),
    );
  }
}

//
class ListingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// CTGDetailView
class CTGDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CTGCubit, CTGAPIState>(builder: (context, state) {
      if (state is LoadingCTG) {
        return Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (state is LoadedCTGFailure) {
        return Container(
          child: Center(
            child: Text("Invalid Image File"),
          ),
        );
      } else if (state is ComputedSQISuccess) {
        return Container(
          child: Center(
            child: Text(state.sqi.summary),
          ),
        );
      } else if (state is LoadedCTGSuccess) {
        return Container(
          child: Center(
            child: Image.network(state.url.url),
          ),
        );
      } else {
        return Container(
          child: Center(
            child: Text("Exception"),
          ),
        );
      }
    });
  }
}
