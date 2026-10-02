// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreUserModel {

 String get id; String get username; String get passwordHash; String get storeId; String get storeName; String get role; bool get active; dynamic get createdAt; dynamic get lastLogin;
/// Create a copy of StoreUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreUserModelCopyWith<StoreUserModel> get copyWith => _$StoreUserModelCopyWithImpl<StoreUserModel>(this as StoreUserModel, _$identity);

  /// Serializes this StoreUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.passwordHash, passwordHash) || other.passwordHash == passwordHash)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastLogin, lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,passwordHash,storeId,storeName,role,active,const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastLogin));

@override
String toString() {
  return 'StoreUserModel(id: $id, username: $username, passwordHash: $passwordHash, storeId: $storeId, storeName: $storeName, role: $role, active: $active, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class $StoreUserModelCopyWith<$Res>  {
  factory $StoreUserModelCopyWith(StoreUserModel value, $Res Function(StoreUserModel) _then) = _$StoreUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String username, String passwordHash, String storeId, String storeName, String role, bool active, dynamic createdAt, dynamic lastLogin
});




}
/// @nodoc
class _$StoreUserModelCopyWithImpl<$Res>
    implements $StoreUserModelCopyWith<$Res> {
  _$StoreUserModelCopyWithImpl(this._self, this._then);

  final StoreUserModel _self;
  final $Res Function(StoreUserModel) _then;

/// Create a copy of StoreUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? passwordHash = null,Object? storeId = null,Object? storeName = null,Object? role = null,Object? active = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,passwordHash: null == passwordHash ? _self.passwordHash : passwordHash // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreUserModel].
extension StoreUserModelPatterns on StoreUserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreUserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreUserModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreUserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreUserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String passwordHash,  String storeId,  String storeName,  String role,  bool active,  dynamic createdAt,  dynamic lastLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreUserModel() when $default != null:
return $default(_that.id,_that.username,_that.passwordHash,_that.storeId,_that.storeName,_that.role,_that.active,_that.createdAt,_that.lastLogin);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String passwordHash,  String storeId,  String storeName,  String role,  bool active,  dynamic createdAt,  dynamic lastLogin)  $default,) {final _that = this;
switch (_that) {
case _StoreUserModel():
return $default(_that.id,_that.username,_that.passwordHash,_that.storeId,_that.storeName,_that.role,_that.active,_that.createdAt,_that.lastLogin);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String passwordHash,  String storeId,  String storeName,  String role,  bool active,  dynamic createdAt,  dynamic lastLogin)?  $default,) {final _that = this;
switch (_that) {
case _StoreUserModel() when $default != null:
return $default(_that.id,_that.username,_that.passwordHash,_that.storeId,_that.storeName,_that.role,_that.active,_that.createdAt,_that.lastLogin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoreUserModel extends StoreUserModel {
  const _StoreUserModel({this.id = '', this.username = '', this.passwordHash = '', this.storeId = '', this.storeName = '', this.role = 'store', this.active = true, this.createdAt, this.lastLogin}): super._();
  factory _StoreUserModel.fromJson(Map<String, dynamic> json) => _$StoreUserModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String username;
@override@JsonKey() final  String passwordHash;
@override@JsonKey() final  String storeId;
@override@JsonKey() final  String storeName;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool active;
@override final  dynamic createdAt;
@override final  dynamic lastLogin;

/// Create a copy of StoreUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreUserModelCopyWith<_StoreUserModel> get copyWith => __$StoreUserModelCopyWithImpl<_StoreUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.passwordHash, passwordHash) || other.passwordHash == passwordHash)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastLogin, lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,passwordHash,storeId,storeName,role,active,const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastLogin));

@override
String toString() {
  return 'StoreUserModel(id: $id, username: $username, passwordHash: $passwordHash, storeId: $storeId, storeName: $storeName, role: $role, active: $active, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class _$StoreUserModelCopyWith<$Res> implements $StoreUserModelCopyWith<$Res> {
  factory _$StoreUserModelCopyWith(_StoreUserModel value, $Res Function(_StoreUserModel) _then) = __$StoreUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String passwordHash, String storeId, String storeName, String role, bool active, dynamic createdAt, dynamic lastLogin
});




}
/// @nodoc
class __$StoreUserModelCopyWithImpl<$Res>
    implements _$StoreUserModelCopyWith<$Res> {
  __$StoreUserModelCopyWithImpl(this._self, this._then);

  final _StoreUserModel _self;
  final $Res Function(_StoreUserModel) _then;

/// Create a copy of StoreUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? passwordHash = null,Object? storeId = null,Object? storeName = null,Object? role = null,Object? active = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_StoreUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,passwordHash: null == passwordHash ? _self.passwordHash : passwordHash // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
