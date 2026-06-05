class UserDto {
  final String id;
  final String email;
  final String name;

  const UserDto({required this.id, required this.email, required this.name});

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
}

class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      AuthResponseDto(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      );
}
