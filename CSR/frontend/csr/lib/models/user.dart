class User {
  final int id;
  final String username;
  final String email;
  final String avatar;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar']
    );
  }

}