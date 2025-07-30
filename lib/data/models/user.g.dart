// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  nom: json['nom'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'email': instance.email,
  'role': instance.role,
  'created_at': instance.createdAt?.toIso8601String(),
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['motDePasse'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'motDePasse': instance.password};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      utilisateur: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'token': instance.token,
      'utilisateur': instance.utilisateur,
    };

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    CreateUserRequest(
      id: json['id'] as String,
      nom: json['nom'] as String,
      email: json['email'] as String,
      password: json['motDePasse'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'email': instance.email,
      'motDePasse': instance.password,
      'role': instance.role,
    };
