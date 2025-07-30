import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model representing a system user
@JsonSerializable()
class User {
  final String id;
  final String nom;
  final String email;
  final String role;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  // Additional fields for client-side use
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? avatarUrl;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isOnline;
  
  const User({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.createdAt,
    this.avatarUrl,
    this.isOnline = false,
  });
  
  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  /// Convert User to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? nom,
    String? email,
    String? role,
    DateTime? createdAt,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
    );
  }
  
  /// Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';
  
  /// Check if user is participant
  bool get isParticipant => role.toLowerCase() == 'participant';
  
  /// Get user initials for avatar
  String get initials {
    final names = nom.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }
  
  /// Get display name
  String get displayName => nom.isNotEmpty ? nom : email;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() {
    return 'User{id: $id, nom: $nom, email: $email, role: $role}';
  }
}

/// Login request model
@JsonSerializable()
class LoginRequest {
  final String email;
  @JsonKey(name: 'motDePasse')
  final String password;
  
  const LoginRequest({
    required this.email,
    required this.password,
  });
  
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Login response model
@JsonSerializable()
class LoginResponse {
  final String message;
  final String token;
  final User utilisateur;
  
  const LoginResponse({
    required this.message,
    required this.token,
    required this.utilisateur,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

/// User creation request model
@JsonSerializable()
class CreateUserRequest {
  final String id;
  final String nom;
  final String email;
  @JsonKey(name: 'motDePasse')
  final String password;
  final String role;
  
  const CreateUserRequest({
    required this.id,
    required this.nom,
    required this.email,
    required this.password,
    required this.role,
  });
  
  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}
