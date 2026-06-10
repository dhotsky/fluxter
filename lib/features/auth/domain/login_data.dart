import 'package:freezed_annotation/freezed_annotation.dart';

import 'token.dart';
import 'user.dart';

part '../../../gen/features/auth/domain/login_data.freezed.dart';
part '../../../gen/features/auth/domain/login_data.g.dart';

@freezed
abstract class LoginData with _$LoginData {
  const factory LoginData({required User user, required Token token}) =
      _LoginData;

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);
}
