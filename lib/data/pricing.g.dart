// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pricing _$PricingFromJson(Map<String, dynamic> json) => Pricing(
      (json['monthlyPrice'] as num?)?.toDouble(),
      (json['annualPrice'] as num?)?.toDouble(),
      json['currency'] as String?,
      json['date'] as String?,
      json['countryId'] as int?,
      json['id'] as int?,
    );

Map<String, dynamic> _$PricingToJson(Pricing instance) => <String, dynamic>{
      'monthlyPrice': instance.monthlyPrice,
      'annualPrice': instance.annualPrice,
      'currency': instance.currency,
      'date': instance.date,
      'countryId': instance.countryId,
      'id': instance.id,
    };
