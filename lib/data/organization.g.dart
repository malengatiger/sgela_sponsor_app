// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) => Organization(
      name: json['name'] as String?,
      email: json['email'] as String?,
      cellphone: json['cellphone'] as String?,
      id: json['id'] as int?,
      country: json['country'] == null
          ? null
          : Country.fromJson(json['country'] as Map<String, dynamic>),
      city: json['city'] == null
          ? null
          : City.fromJson(json['city'] as Map<String, dynamic>),
      logoUrl: json['logoUrl'] as String?,
      splashUrl: json['splashUrl'] as String?,
      adminUser: json['adminUser'] == null
          ? null
          : User.fromJson(json['adminUser'] as Map<String, dynamic>),
      coverageRadiusInKM: json['coverageRadiusInKM'] as int?,
      date: json['date'] as String?,
      exclusiveCoverage: json['exclusiveCoverage'] as bool?,
      tagLine: json['tagLine'] as String?,
    );

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'cellphone': instance.cellphone,
      'id': instance.id,
      'country': instance.country,
      'city': instance.city,
      'coverageRadiusInKM': instance.coverageRadiusInKM,
      'date': instance.date,
      'exclusiveCoverage': instance.exclusiveCoverage,
      'logoUrl': instance.logoUrl,
      'splashUrl': instance.splashUrl,
      'tagLine': instance.tagLine,
      'adminUser': instance.adminUser,
    };
