// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserModel {

 String get id; String get username; String get passwordHash; String get role; bool get active; String get name; String get email; dynamic get createdAt; dynamic get lastLogin;
/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserModelCopyWith<AdminUserModel> get copyWith => _$AdminUserModelCopyWithImpl<AdminUserModel>(this as AdminUserModel, _$identity);

  /// Serializes this AdminUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.passwordHash, passwordHash) || other.passwordHash == passwordHash)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastLogin, lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,passwordHash,role,active,name,email,const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastLogin));

@override
String toString() {
  return 'AdminUserModel(id: $id, username: $username, passwordHash: $passwordHash, role: $role, active: $active, name: $name, email: $email, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class $AdminUserModelCopyWith<$Res>  {
  factory $AdminUserModelCopyWith(AdminUserModel value, $Res Function(AdminUserModel) _then) = _$AdminUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String username, String passwordHash, String role, bool active, String name, String email, dynamic createdAt, dynamic lastLogin
});




}
/// @nodoc
class _$AdminUserModelCopyWithImpl<$Res>
    implements $AdminUserModelCopyWith<$Res> {
  _$AdminUserModelCopyWithImpl(this._self, this._then);

  final AdminUserModel _self;
  final $Res Function(AdminUserModel) _then;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? passwordHash = null,Object? role = null,Object? active = null,Object? name = null,Object? email = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,passwordHash: null == passwordHash ? _self.passwordHash : passwordHash // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserModel].
extension AdminUserModelPatterns on AdminUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserModel value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String passwordHash,  String role,  bool active,  String name,  String email,  dynamic createdAt,  dynamic lastLogin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
return $default(_that.id,_that.username,_that.passwordHash,_that.role,_that.active,_that.name,_that.email,_that.createdAt,_that.lastLogin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String passwordHash,  String role,  bool active,  String name,  String email,  dynamic createdAt,  dynamic lastLogin)  $default,) {final _that = this;
switch (_that) {
case _AdminUserModel():
return $default(_that.id,_that.username,_that.passwordHash,_that.role,_that.active,_that.name,_that.email,_that.createdAt,_that.lastLogin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String passwordHash,  String role,  bool active,  String name,  String email,  dynamic createdAt,  dynamic lastLogin)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
return $default(_that.id,_that.username,_that.passwordHash,_that.role,_that.active,_that.name,_that.email,_that.createdAt,_that.lastLogin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserModel extends AdminUserModel {
  const _AdminUserModel({this.id = '', this.username = '', this.passwordHash = '', this.role = 'admin', this.active = true, this.name = '', this.email = '', this.createdAt, this.lastLogin}): super._();
  factory _AdminUserModel.fromJson(Map<String, dynamic> json) => _$AdminUserModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String username;
@override@JsonKey() final  String passwordHash;
@override@JsonKey() final  String role;
@override@JsonKey() final  bool active;
@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override final  dynamic createdAt;
@override final  dynamic lastLogin;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserModelCopyWith<_AdminUserModel> get copyWith => __$AdminUserModelCopyWithImpl<_AdminUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.passwordHash, passwordHash) || other.passwordHash == passwordHash)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastLogin, lastLogin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,passwordHash,role,active,name,email,const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastLogin));

@override
String toString() {
  return 'AdminUserModel(id: $id, username: $username, passwordHash: $passwordHash, role: $role, active: $active, name: $name, email: $email, createdAt: $createdAt, lastLogin: $lastLogin)';
}


}

/// @nodoc
abstract mixin class _$AdminUserModelCopyWith<$Res> implements $AdminUserModelCopyWith<$Res> {
  factory _$AdminUserModelCopyWith(_AdminUserModel value, $Res Function(_AdminUserModel) _then) = __$AdminUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String passwordHash, String role, bool active, String name, String email, dynamic createdAt, dynamic lastLogin
});




}
/// @nodoc
class __$AdminUserModelCopyWithImpl<$Res>
    implements _$AdminUserModelCopyWith<$Res> {
  __$AdminUserModelCopyWithImpl(this._self, this._then);

  final _AdminUserModel _self;
  final $Res Function(_AdminUserModel) _then;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? passwordHash = null,Object? role = null,Object? active = null,Object? name = null,Object? email = null,Object? createdAt = freezed,Object? lastLogin = freezed,}) {
  return _then(_AdminUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,passwordHash: null == passwordHash ? _self.passwordHash : passwordHash // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastLogin: freezed == lastLogin ? _self.lastLogin : lastLogin // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
