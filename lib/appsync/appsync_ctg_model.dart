class CTGRecordModel {
  final String username;
  final String ctgUrl;
  final String createdAt;

  CTGRecordModel({
    this.username,
    this.ctgUrl,
    this.createdAt
  });

  factory CTGRecordModel.fromJson(Map<String, dynamic> json){
    // TODO try catch or default value
    final username = json['username'];
    final ctgUrl = json['ctgUrl'];
    final createdAt = json['createdAt'];

    return CTGRecordModel(
      username: username,
      ctgUrl: ctgUrl,
      createdAt: createdAt,
    );
  }
}
