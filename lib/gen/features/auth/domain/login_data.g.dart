// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../features/auth/domain/login_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginData _$LoginDataFromJson(Map<String, dynamic> json) => _LoginData(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  token: Token.fromJson(json['token'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginDataToJson(_LoginData instance) =>
    <String, dynamic>{'user': instance.user, 'token': instance.token};
