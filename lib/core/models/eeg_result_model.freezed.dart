// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eeg_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EEGResultModel {

 String get id; String get userId; String get storeId; String get perfumeId; String get perfumeName; double get relaxation; double get attention; double get engagement; double get excitement; double get stress; double get interest; Map<String, dynamic> get rawData; dynamic get createdAt;
/// Create a copy of EEGResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EEGResultModelCopyWith<EEGResultModel> get copyWith => _$EEGResultModelCopyWithImpl<EEGResultModel>(this as EEGResultModel, _$identity);

  /// Serializes this EEGResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EEGResultModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.perfumeId, perfumeId) || other.perfumeId == perfumeId)&&(identical(other.perfumeName, perfumeName) || other.perfumeName == perfumeName)&&(identical(other.relaxation, relaxation) || other.relaxation == relaxation)&&(identical(other.attention, attention) || other.attention == attention)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.excitement, excitement) || other.excitement == excitement)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.interest, interest) || other.interest == interest)&&const DeepCollectionEquality().equals(other.rawData, rawData)&&const DeepCollectionEquality().equals(other.createdAt, createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,perfumeId,perfumeName,relaxation,attention,engagement,excitement,stress,interest,const DeepCollectionEquality().hash(rawData),const DeepCollectionEquality().hash(createdAt));

@override
String toString() {
  return 'EEGResultModel(id: $id, userId: $userId, storeId: $storeId, perfumeId: $perfumeId, perfumeName: $perfumeName, relaxation: $relaxation, attention: $attention, engagement: $engagement, excitement: $excitement, stress: $stress, interest: $interest, rawData: $rawData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EEGResultModelCopyWith<$Res>  {
  factory $EEGResultModelCopyWith(EEGResultModel value, $Res Function(EEGResultModel) _then) = _$EEGResultModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String storeId, String perfumeId, String perfumeName, double relaxation, double attention, double engagement, double excitement, double stress, double interest, Map<String, dynamic> rawData, dynamic createdAt
});




}
/// @nodoc
class _$EEGResultModelCopyWithImpl<$Res>
    implements $EEGResultModelCopyWith<$Res> {
  _$EEGResultModelCopyWithImpl(this._self, this._then);

  final EEGResultModel _self;
  final $Res Function(EEGResultModel) _then;

/// Create a copy of EEGResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? storeId = null,Object? perfumeId = null,Object? perfumeName = null,Object? relaxation = null,Object? attention = null,Object? engagement = null,Object? excitement = null,Object? stress = null,Object? interest = null,Object? rawData = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,perfumeId: null == perfumeId ? _self.perfumeId : perfumeId // ignore: cast_nullable_to_non_nullable
as String,perfumeName: null == perfumeName ? _self.perfumeName : perfumeName // ignore: cast_nullable_to_non_nullable
as String,relaxation: null == relaxation ? _self.relaxation : relaxation // ignore: cast_nullable_to_non_nullable
as double,attention: null == attention ? _self.attention : attention // ignore: cast_nullable_to_non_nullable
as double,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as double,excitement: null == excitement ? _self.excitement : excitement // ignore: cast_nullable_to_non_nullable
as double,stress: null == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as double,interest: null == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as double,rawData: null == rawData ? _self.rawData : rawData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [EEGResultModel].
extension EEGResultModelPatterns on EEGResultModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EEGResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EEGResultModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EEGResultModel value)  $default,){
final _that = this;
switch (_that) {
case _EEGResultModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EEGResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _EEGResultModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  double relaxation,  double attention,  double engagement,  double excitement,  double stress,  double interest,  Map<String, dynamic> rawData,  dynamic createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EEGResultModel() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.relaxation,_that.attention,_that.engagement,_that.excitement,_that.stress,_that.interest,_that.rawData,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  double relaxation,  double attention,  double engagement,  double excitement,  double stress,  double interest,  Map<String, dynamic> rawData,  dynamic createdAt)  $default,) {final _that = this;
switch (_that) {
case _EEGResultModel():
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.relaxation,_that.attention,_that.engagement,_that.excitement,_that.stress,_that.interest,_that.rawData,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  double relaxation,  double attention,  double engagement,  double excitement,  double stress,  double interest,  Map<String, dynamic> rawData,  dynamic createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EEGResultModel() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.relaxation,_that.attention,_that.engagement,_that.excitement,_that.stress,_that.interest,_that.rawData,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EEGResultModel extends EEGResultModel {
  const _EEGResultModel({this.id = '', this.userId = '', this.storeId = '', this.perfumeId = '', this.perfumeName = '', this.relaxation = 0.0, this.attention = 0.0, this.engagement = 0.0, this.excitement = 0.0, this.stress = 0.0, this.interest = 0.0, final  Map<String, dynamic> rawData = const <String, dynamic>{}, this.createdAt}): _rawData = rawData,super._();
  factory _EEGResultModel.fromJson(Map<String, dynamic> json) => _$EEGResultModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String userId;
@override@JsonKey() final  String storeId;
@override@JsonKey() final  String perfumeId;
@override@JsonKey() final  String perfumeName;
@override@JsonKey() final  double relaxation;
@override@JsonKey() final  double attention;
@override@JsonKey() final  double engagement;
@override@JsonKey() final  double excitement;
@override@JsonKey() final  double stress;
@override@JsonKey() final  double interest;
 final  Map<String, dynamic> _rawData;
@override@JsonKey() Map<String, dynamic> get rawData {
  if (_rawData is EqualUnmodifiableMapView) return _rawData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawData);
}

@override final  dynamic createdAt;

/// Create a copy of EEGResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EEGResultModelCopyWith<_EEGResultModel> get copyWith => __$EEGResultModelCopyWithImpl<_EEGResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EEGResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EEGResultModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.perfumeId, perfumeId) || other.perfumeId == perfumeId)&&(identical(other.perfumeName, perfumeName) || other.perfumeName == perfumeName)&&(identical(other.relaxation, relaxation) || other.relaxation == relaxation)&&(identical(other.attention, attention) || other.attention == attention)&&(identical(other.engagement, engagement) || other.engagement == engagement)&&(identical(other.excitement, excitement) || other.excitement == excitement)&&(identical(other.stress, stress) || other.stress == stress)&&(identical(other.interest, interest) || other.interest == interest)&&const DeepCollectionEquality().equals(other._rawData, _rawData)&&const DeepCollectionEquality().equals(other.createdAt, createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,perfumeId,perfumeName,relaxation,attention,engagement,excitement,stress,interest,const DeepCollectionEquality().hash(_rawData),const DeepCollectionEquality().hash(createdAt));

@override
String toString() {
  return 'EEGResultModel(id: $id, userId: $userId, storeId: $storeId, perfumeId: $perfumeId, perfumeName: $perfumeName, relaxation: $relaxation, attention: $attention, engagement: $engagement, excitement: $excitement, stress: $stress, interest: $interest, rawData: $rawData, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EEGResultModelCopyWith<$Res> implements $EEGResultModelCopyWith<$Res> {
  factory _$EEGResultModelCopyWith(_EEGResultModel value, $Res Function(_EEGResultModel) _then) = __$EEGResultModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String storeId, String perfumeId, String perfumeName, double relaxation, double attention, double engagement, double excitement, double stress, double interest, Map<String, dynamic> rawData, dynamic createdAt
});




}
/// @nodoc
class __$EEGResultModelCopyWithImpl<$Res>
    implements _$EEGResultModelCopyWith<$Res> {
  __$EEGResultModelCopyWithImpl(this._self, this._then);

  final _EEGResultModel _self;
  final $Res Function(_EEGResultModel) _then;

/// Create a copy of EEGResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? storeId = null,Object? perfumeId = null,Object? perfumeName = null,Object? relaxation = null,Object? attention = null,Object? engagement = null,Object? excitement = null,Object? stress = null,Object? interest = null,Object? rawData = null,Object? createdAt = freezed,}) {
  return _then(_EEGResultModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,perfumeId: null == perfumeId ? _self.perfumeId : perfumeId // ignore: cast_nullable_to_non_nullable
as String,perfumeName: null == perfumeName ? _self.perfumeName : perfumeName // ignore: cast_nullable_to_non_nullable
as String,relaxation: null == relaxation ? _self.relaxation : relaxation // ignore: cast_nullable_to_non_nullable
as double,attention: null == attention ? _self.attention : attention // ignore: cast_nullable_to_non_nullable
as double,engagement: null == engagement ? _self.engagement : engagement // ignore: cast_nullable_to_non_nullable
as double,excitement: null == excitement ? _self.excitement : excitement // ignore: cast_nullable_to_non_nullable
as double,stress: null == stress ? _self.stress : stress // ignore: cast_nullable_to_non_nullable
as double,interest: null == interest ? _self.interest : interest // ignore: cast_nullable_to_non_nullable
as double,rawData: null == rawData ? _self._rawData : rawData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
