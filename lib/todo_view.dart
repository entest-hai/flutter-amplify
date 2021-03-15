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
              Expanded(
                child: ListView.builder(
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
