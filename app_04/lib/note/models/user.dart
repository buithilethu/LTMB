class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      passwordHash: map['passwordHash'],
    );
  }
}
