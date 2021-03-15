import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'dart:convert';

// Todo Data Modal
class Todo {
  final String name;
  final String description;
  Todo({this.name, this.description});

  factory Todo.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final description = json['description'];
    return Todo(name: name, description: description);
  }
}

// Todo Repository
class TodoRepository {
  Future<List<Todo>> fetchTodo() async {
    print("fetch todo from db");
    List<Todo> _todos = [];
    try {
      String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          name
          description
        }
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      var items = jsonDecode(response.data.toString())['listTodos']['items'];
      for (var item in items) {
        // print(item['name']);
        _todos.add(Todo.fromJson(item));
      }

      return _todos;
    } on ApiException catch (e) {
      print('Query failed: $e');
      return _todos;
    }
  }
}
