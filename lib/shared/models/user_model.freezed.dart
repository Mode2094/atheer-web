// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get id; String get name; String get phone; String get country; String get gender; Map<String, dynamic> get personalityProfile; List<String> get pastRecommendations; dynamic get createdAt; dynamic get lastActive; dynamic get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.country, country) || other.country == country)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.personalityProfile, personalityProfile)&&const DeepCollectionEquality().equals(other.pastRecommendations, pastRecommendations)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastActive, lastActive)&&const DeepCollectionEquality().equals(other.updatedAt, updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,country,gender,const DeepCollectionEquality().hash(personalityProfile),const DeepCollectionEquality().hash(pastRecommendations),const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastActive),const DeepCollectionEquality().hash(updatedAt));

@override
String toString() {
  return 'UserModel(id: $id, name: $name, phone: $phone, country: $country, gender: $gender, personalityProfile: $personalityProfile, pastRecommendations: $pastRecommendations, createdAt: $createdAt, lastActive: $lastActive, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String phone, String country, String gender, Map<String, dynamic> personalityProfile, List<String> pastRecommendations, dynamic createdAt, dynamic lastActive, dynamic updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? country = null,Object? gender = null,Object? personalityProfile = null,Object? pastRecommendations = null,Object? createdAt = freezed,Object? lastActive = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,personalityProfile: null == personalityProfile ? _self.personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pastRecommendations: null == pastRecommendations ? _self.pastRecommendations : pastRecommendations // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as dynamic,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String country,  String gender,  Map<String, dynamic> personalityProfile,  List<String> pastRecommendations,  dynamic createdAt,  dynamic lastActive,  dynamic updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.country,_that.gender,_that.personalityProfile,_that.pastRecommendations,_that.createdAt,_that.lastActive,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String phone,  String country,  String gender,  Map<String, dynamic> personalityProfile,  List<String> pastRecommendations,  dynamic createdAt,  dynamic lastActive,  dynamic updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.name,_that.phone,_that.country,_that.gender,_that.personalityProfile,_that.pastRecommendations,_that.createdAt,_that.lastActive,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String phone,  String country,  String gender,  Map<String, dynamic> personalityProfile,  List<String> pastRecommendations,  dynamic createdAt,  dynamic lastActive,  dynamic updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.name,_that.phone,_that.country,_that.gender,_that.personalityProfile,_that.pastRecommendations,_that.createdAt,_that.lastActive,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({this.id = '', this.name = '', this.phone = '', this.country = '', this.gender = '', final  Map<String, dynamic> personalityProfile = const <String, dynamic>{}, final  List<String> pastRecommendations = const <String>[], this.createdAt, this.lastActive, this.updatedAt}): _personalityProfile = personalityProfile,_pastRecommendations = pastRecommendations,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String country;
@override@JsonKey() final  String gender;
 final  Map<String, dynamic> _personalityProfile;
@override@JsonKey() Map<String, dynamic> get personalityProfile {
  if (_personalityProfile is EqualUnmodifiableMapView) return _personalityProfile;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_personalityProfile);
}

 final  List<String> _pastRecommendations;
@override@JsonKey() List<String> get pastRecommendations {
  if (_pastRecommendations is EqualUnmodifiableListView) return _pastRecommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pastRecommendations);
}

@override final  dynamic createdAt;
@override final  dynamic lastActive;
@override final  dynamic updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.country, country) || other.country == country)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._personalityProfile, _personalityProfile)&&const DeepCollectionEquality().equals(other._pastRecommendations, _pastRecommendations)&&const DeepCollectionEquality().equals(other.createdAt, createdAt)&&const DeepCollectionEquality().equals(other.lastActive, lastActive)&&const DeepCollectionEquality().equals(other.updatedAt, updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,phone,country,gender,const DeepCollectionEquality().hash(_personalityProfile),const DeepCollectionEquality().hash(_pastRecommendations),const DeepCollectionEquality().hash(createdAt),const DeepCollectionEquality().hash(lastActive),const DeepCollectionEquality().hash(updatedAt));

@override
String toString() {
  return 'UserModel(id: $id, name: $name, phone: $phone, country: $country, gender: $gender, personalityProfile: $personalityProfile, pastRecommendations: $pastRecommendations, createdAt: $createdAt, lastActive: $lastActive, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String phone, String country, String gender, Map<String, dynamic> personalityProfile, List<String> pastRecommendations, dynamic createdAt, dynamic lastActive, dynamic updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? phone = null,Object? country = null,Object? gender = null,Object? personalityProfile = null,Object? pastRecommendations = null,Object? createdAt = freezed,Object? lastActive = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,personalityProfile: null == personalityProfile ? _self._personalityProfile : personalityProfile // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,pastRecommendations: null == pastRecommendations ? _self._pastRecommendations : pastRecommendations // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as dynamic,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
