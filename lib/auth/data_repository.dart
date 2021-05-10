import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter_amplify/auth/models/user_model.dart';


class DataRepository {
  // Query DB to get user by userId
  Future<User> getUserById(String userId) async {
    print("trying to get user from db $userId");

    try {
      String graphQLDocument = '''query getUser {
      getUser(id: "$userId") {
        email
        id
        description
        username
        avatarKey
      }
    }''';

      var operation = Amplify.API
          .query(request: GraphQLRequest<String>(document: graphQLDocument));

      var response = await operation.response;
      var json = jsonDecode(response.data.toString())['getUser'];
      print(json);
      return User.fromJson(json);
    } catch (e) {
      print(e);
    }

    return User(
        id: '', username: '', email: '', avatarkey: '', description: '');
  }

  // Mutation to create a new user
  Future<User> createUser({
    String userId,
    String username,
    String email,
  }) async {
    final newUser = User(
        id: userId,
        username: username,
        email: email,
        avatarkey: '',
        description: '');

    await Future.delayed(Duration(seconds: 3));
    print("create user into DB");
    return newUser;
  }
}
