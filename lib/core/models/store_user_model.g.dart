// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreUserModel _$StoreUserModelFromJson(Map<String, dynamic> json) =>
    _StoreUserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      role: json['role'] as String? ?? 'store',
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'],
      lastLogin: json['lastLogin'],
    );

Map<String, dynamic> _$StoreUserModelToJson(_StoreUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'passwordHash': instance.passwordHash,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'role': instance.role,
      'active': instance.active,
      'createdAt': instance.createdAt,
      'lastLogin': instance.lastLogin,
    };
