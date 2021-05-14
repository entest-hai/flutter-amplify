import 'dart:convert';

class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String avatarkey;
  final String description;
  final int version;

  User({
    this.id,
    this.username,
    this.password,
    this.email,
    this.avatarkey,
    this.description,
    this.version});

  factory User.fromJson(Map<String, dynamic> json) {

    final version = json['_version'] as int; 
    print("version $version");

    return User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        avatarkey: json['avatarKey'],
        description: json['description'],
        version: json['_version'] as int
        );
  }

   User copyWith(
      {String id,
      String username,
      String email,
      String avatarkey,
      String description}) {
    return User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        avatarkey: avatarkey ?? this.avatarkey,
        description: description ?? this.description,
        version: version ?? this.version
        );
  }

}
