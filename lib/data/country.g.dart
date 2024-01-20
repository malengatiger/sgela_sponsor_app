// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      json['id'] as int?,
      json['name'] as String?,
      json['capital'] as String?,
      json['currencyName'] as String?,
      json['currencySymbol'] as String?,
      json['emoji'] as String?,
      json['iso2'] as String?,
      json['iso3'] as String?,
      json['phoneCode'] as String?,
      json['region'] as String?,
      json['subregion'] as String?,
      json['numericCode'] as String?,
      (json['latitude'] as num?)?.toDouble(),
      (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capital': instance.capital,
      'currencyName': instance.currencyName,
      'currencySymbol': instance.currencySymbol,
      'emoji': instance.emoji,
      'iso2': instance.iso2,
      'iso3': instance.iso3,
      'phoneCode': instance.phoneCode,
      'region': instance.region,
      'subregion': instance.subregion,
      'numericCode': instance.numericCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
