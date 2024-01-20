import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String? firstName, lastName, email, cellphone;
  String? date, password;
  String? firebaseUserId;

  int? id;
  String? profileUrl;
  bool? activeFlag;
  int? organizationId;

  String? organizationName;

  int? subscriptionId;
  String? subscriptionDate;

  User(
      {this.firstName,
      this.lastName,
      this.email,
      this.cellphone,
      this.date,
      this.password,
      this.firebaseUserId,
      this.id,
      this.profileUrl,
      this.activeFlag,
      this.organizationId,
        this.organizationName,
      this.subscriptionId,
      this.subscriptionDate});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
