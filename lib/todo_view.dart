import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'todo_cubit.dart';

class TodoDBView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TodoDBState();
  }
}

class _TodoDBState extends State<TodoDBView> {
  var _hasReachMax = false;
  final _scrollController = ScrollController();
  final _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      _onScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final minScroll = _scrollController.position.minScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (minScroll - currentScroll > _scrollThreshold) {
      if (!_hasReachMax) {
        fetchData();
      }
    }
  }

  Future<void> fetchData() async {
    print("fetch more message now");
    setState(() {
      _hasReachMax = true;
    });

    BlocProvider.of<TodoCubit>(context).fetchTodo();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _hasReachMax = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is LoadingTodo) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is LoadedTodoSuccess) {
          return Column(
            children: [
              _hasReachMax ? BottomLoader() : SizedBox(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                          title: Text(state.todos[index].name +
                              " " +
                              state.todos[index].description)),
                    );
                  },
                ),
              ),
              IconButton(
                  icon:
                      Icon(Icons.cloud_download, size: 50, color: Colors.blue),
                  onPressed: () {
                    BlocProvider.of<TodoCubit>(context).fetchTodo();
                  }),
              SizedBox(
                height: 10,
              ),
            ],
          );
          ;
        } else {
          return Container(
            child: Center(
              child: Text("Exception"),
            ),
          );
        }
      },
    );
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
