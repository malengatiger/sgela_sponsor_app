// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['firstName'] as String?,
      json['lastName'] as String?,
      json['email'] as String?,
      json['cellphone'] as String?,
      json['date'] as String?,
      json['password'] as String?,
    )
      ..firebaseUserId = json['firebaseUserId'] as String?
      ..profileUrl = json['profileUrl'] as String?
      ..activeFlag = json['activeFlag'] as bool?
      ..organizationId = json['organizationId'] as int?
      ..subscriptionId = json['subscriptionId'] as int?
      ..subscriptionDate = json['subscriptionDate'] as String?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'cellphone': instance.cellphone,
      'date': instance.date,
      'password': instance.password,
      'firebaseUserId': instance.firebaseUserId,
      'profileUrl': instance.profileUrl,
      'activeFlag': instance.activeFlag,
      'organizationId': instance.organizationId,
      'subscriptionId': instance.subscriptionId,
      'subscriptionDate': instance.subscriptionDate,
    };
