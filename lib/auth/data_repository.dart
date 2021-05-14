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
        _version
      }
    }''';

      var operation = Amplify.API.query(request: GraphQLRequest<String>(document: graphQLDocument));
      var response = await operation.response;
      var json = jsonDecode(response.data.toString())['getUser'];
      var user = User.fromJson(json);
      print(json);
      print("user version ${user.version}");
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
    print("create user into DB");
    String graphQLDocument = '''mutation createUser {
      createUser(input: {email: "$email", id: "$userId", username: "$username"}) {
      email
      id
      username
      }
    }''';
    var operation = Amplify.API.query(request: GraphQLRequest<String>(document: graphQLDocument));
    try {
      var response = await operation.response;
      var json = jsonDecode(response.data.toString())['createUser'];
      print(json);
    } catch(e) {
      throw(e);
    }
    return newUser;
  }

  // Update user 
  Future<User> updateUser(User updatedUser) async {
    print("update user image profile key ${updatedUser.avatarkey} version ${updatedUser.version}");
    String graphQLDocument = '''mutation updateUser {
        updateUser(input: {id: "${updatedUser.id}", avatarKey: "${updatedUser.avatarkey}", _version: ${updatedUser.version}}) {
          id
          description
          email  
          username
          avatarKey
          _version
          }
        }''';
    var operation = Amplify.API.query(request: GraphQLRequest<String>(document: graphQLDocument));
    try {
      var response = await operation.response;
      print("${response.toString()}");
      print(jsonDecode(response.data.toString()));
      var json = jsonDecode(response.data.toString())['updateUser'];
      print(json);
    } catch (e) {
      throw(e);
    }
    return updatedUser;
  }


}
