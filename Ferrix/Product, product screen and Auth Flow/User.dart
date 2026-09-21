// lib/auth/models/user.dart
class User {
  final String id;
  final String email;
  final String? displayName;

  const User({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
      };
}