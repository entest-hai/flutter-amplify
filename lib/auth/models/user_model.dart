class User {
  final String id;
  final String username;
  final String email;
  final String avatarkey;
  final String description;

  User({this.id, this.username, this.email, this.avatarkey, this.description});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        avatarkey: json['avatarKey'],
        description: json['description']);
  }
}
