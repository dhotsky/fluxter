import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../gen/features/auth/domain/user.freezed.dart';
part '../../../gen/features/auth/domain/user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'email') String? email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
