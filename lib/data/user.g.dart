// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      cellphone: json['cellphone'] as String?,
      date: json['date'] as String?,
      password: json['password'] as String?,
      firebaseUserId: json['firebaseUserId'] as String?,
      id: json['id'] as int?,
      profileUrl: json['profileUrl'] as String?,
      activeFlag: json['activeFlag'] as bool?,
      organizationId: json['organizationId'] as int?,
      organizationName: json['organizationName'] as String?,
      subscriptionId: json['subscriptionId'] as int?,
      subscriptionDate: json['subscriptionDate'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'cellphone': instance.cellphone,
      'date': instance.date,
      'password': instance.password,
      'firebaseUserId': instance.firebaseUserId,
      'id': instance.id,
      'profileUrl': instance.profileUrl,
      'activeFlag': instance.activeFlag,
      'organizationId': instance.organizationId,
      'organizationName': instance.organizationName,
      'subscriptionId': instance.subscriptionId,
      'subscriptionDate': instance.subscriptionDate,
    };
