import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../gen/features/auth/domain/token.freezed.dart';
part '../../../gen/features/auth/domain/token.g.dart';

@freezed
abstract class Token with _$Token {
  const factory Token({
    @JsonKey(name: 'access_token') String? accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
  }) = _Token;

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
