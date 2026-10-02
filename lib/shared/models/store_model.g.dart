// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => _StoreModel(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  logo: json['logo'] as String? ?? '',
  address: json['address'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  uniqueCode: json['uniqueCode'] as String? ?? '',
  active: json['active'] as bool? ?? true,
  createdAt: json['createdAt'],
);

Map<String, dynamic> _$StoreModelToJson(_StoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo': instance.logo,
      'address': instance.address,
      'phone': instance.phone,
      'uniqueCode': instance.uniqueCode,
      'active': instance.active,
      'createdAt': instance.createdAt,
    };
