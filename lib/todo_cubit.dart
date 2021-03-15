import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'todo_repository.dart';

// Todo Cubit
abstract class TodoState {}

class LoadingTodo extends TodoState {}

class LoadedTodoSuccess extends TodoState {
  final List<Todo> todos;
  LoadedTodoSuccess({this.todos});
}

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository = TodoRepository();
  TodoCubit() : super(LoadingTodo());

  void fetchTodo() async {
    final todos = await _todoRepository.fetchTodo();
    emit(LoadedTodoSuccess(todos: todos));
  }

  void subscribeTodo() async {
    // load data
    final todos = await _todoRepository.fetchTodo();
    emit(LoadedTodoSuccess(todos: todos));
    // observe changes
    try {
      String graphQLDocument = '''subscription OnCreateTodo {
        onCreateTodo {
          id
          name
          description
        }
      }''';

      var operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            // print('Subscription event data received: ${event.data}');
            todos.add(Todo.fromJson(
                jsonDecode(event.data.toString())['onCreateTodo']));
            emit(LoadedTodoSuccess(todos: todos));
          },
          onEstablished: () {
            print('Subscription established');
          },
          onError: (e) {
            print('Subscription failed with error: $e');
          },
          onDone: () {
            print('Subscription has been closed successfully');
          });
    } on ApiException catch (e) {
      print('Failed to establish subscription: $e');
    }
  }
}
