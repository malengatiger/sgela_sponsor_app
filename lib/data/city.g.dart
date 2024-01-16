// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
      json['id'] as int?,
      json['name'] as String?,
      json['stateId'] as int?,
      json['countryId'] as int?,
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stateId': instance.stateId,
      'countryId': instance.countryId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
