// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecommendationModel {

 String get id; String get userId; String get storeId; String get perfumeId; String get perfumeName; String get perfumeFamily; String get reason;// Why this perfume was recommended
 double get confidenceScore;// 0.0 to 1.0
 bool get wasEegUsed;// Whether EEG data was used
 dynamic get createdAt;
/// Create a copy of RecommendationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationModelCopyWith<RecommendationModel> get copyWith => _$RecommendationModelCopyWithImpl<RecommendationModel>(this as RecommendationModel, _$identity);

  /// Serializes this RecommendationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.perfumeId, perfumeId) || other.perfumeId == perfumeId)&&(identical(other.perfumeName, perfumeName) || other.perfumeName == perfumeName)&&(identical(other.perfumeFamily, perfumeFamily) || other.perfumeFamily == perfumeFamily)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.wasEegUsed, wasEegUsed) || other.wasEegUsed == wasEegUsed)&&const DeepCollectionEquality().equals(other.createdAt, createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,perfumeId,perfumeName,perfumeFamily,reason,confidenceScore,wasEegUsed,const DeepCollectionEquality().hash(createdAt));

@override
String toString() {
  return 'RecommendationModel(id: $id, userId: $userId, storeId: $storeId, perfumeId: $perfumeId, perfumeName: $perfumeName, perfumeFamily: $perfumeFamily, reason: $reason, confidenceScore: $confidenceScore, wasEegUsed: $wasEegUsed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $RecommendationModelCopyWith<$Res>  {
  factory $RecommendationModelCopyWith(RecommendationModel value, $Res Function(RecommendationModel) _then) = _$RecommendationModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String storeId, String perfumeId, String perfumeName, String perfumeFamily, String reason, double confidenceScore, bool wasEegUsed, dynamic createdAt
});




}
/// @nodoc
class _$RecommendationModelCopyWithImpl<$Res>
    implements $RecommendationModelCopyWith<$Res> {
  _$RecommendationModelCopyWithImpl(this._self, this._then);

  final RecommendationModel _self;
  final $Res Function(RecommendationModel) _then;

/// Create a copy of RecommendationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? storeId = null,Object? perfumeId = null,Object? perfumeName = null,Object? perfumeFamily = null,Object? reason = null,Object? confidenceScore = null,Object? wasEegUsed = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,perfumeId: null == perfumeId ? _self.perfumeId : perfumeId // ignore: cast_nullable_to_non_nullable
as String,perfumeName: null == perfumeName ? _self.perfumeName : perfumeName // ignore: cast_nullable_to_non_nullable
as String,perfumeFamily: null == perfumeFamily ? _self.perfumeFamily : perfumeFamily // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,wasEegUsed: null == wasEegUsed ? _self.wasEegUsed : wasEegUsed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationModel].
extension RecommendationModelPatterns on RecommendationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationModel value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationModel value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  String perfumeFamily,  String reason,  double confidenceScore,  bool wasEegUsed,  dynamic createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationModel() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.perfumeFamily,_that.reason,_that.confidenceScore,_that.wasEegUsed,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  String perfumeFamily,  String reason,  double confidenceScore,  bool wasEegUsed,  dynamic createdAt)  $default,) {final _that = this;
switch (_that) {
case _RecommendationModel():
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.perfumeFamily,_that.reason,_that.confidenceScore,_that.wasEegUsed,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String storeId,  String perfumeId,  String perfumeName,  String perfumeFamily,  String reason,  double confidenceScore,  bool wasEegUsed,  dynamic createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationModel() when $default != null:
return $default(_that.id,_that.userId,_that.storeId,_that.perfumeId,_that.perfumeName,_that.perfumeFamily,_that.reason,_that.confidenceScore,_that.wasEegUsed,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationModel extends RecommendationModel {
  const _RecommendationModel({this.id = '', this.userId = '', this.storeId = '', this.perfumeId = '', this.perfumeName = '', this.perfumeFamily = '', this.reason = '', this.confidenceScore = 0.0, this.wasEegUsed = false, this.createdAt}): super._();
  factory _RecommendationModel.fromJson(Map<String, dynamic> json) => _$RecommendationModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String userId;
@override@JsonKey() final  String storeId;
@override@JsonKey() final  String perfumeId;
@override@JsonKey() final  String perfumeName;
@override@JsonKey() final  String perfumeFamily;
@override@JsonKey() final  String reason;
// Why this perfume was recommended
@override@JsonKey() final  double confidenceScore;
// 0.0 to 1.0
@override@JsonKey() final  bool wasEegUsed;
// Whether EEG data was used
@override final  dynamic createdAt;

/// Create a copy of RecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationModelCopyWith<_RecommendationModel> get copyWith => __$RecommendationModelCopyWithImpl<_RecommendationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.perfumeId, perfumeId) || other.perfumeId == perfumeId)&&(identical(other.perfumeName, perfumeName) || other.perfumeName == perfumeName)&&(identical(other.perfumeFamily, perfumeFamily) || other.perfumeFamily == perfumeFamily)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&(identical(other.wasEegUsed, wasEegUsed) || other.wasEegUsed == wasEegUsed)&&const DeepCollectionEquality().equals(other.createdAt, createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,storeId,perfumeId,perfumeName,perfumeFamily,reason,confidenceScore,wasEegUsed,const DeepCollectionEquality().hash(createdAt));

@override
String toString() {
  return 'RecommendationModel(id: $id, userId: $userId, storeId: $storeId, perfumeId: $perfumeId, perfumeName: $perfumeName, perfumeFamily: $perfumeFamily, reason: $reason, confidenceScore: $confidenceScore, wasEegUsed: $wasEegUsed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RecommendationModelCopyWith<$Res> implements $RecommendationModelCopyWith<$Res> {
  factory _$RecommendationModelCopyWith(_RecommendationModel value, $Res Function(_RecommendationModel) _then) = __$RecommendationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String storeId, String perfumeId, String perfumeName, String perfumeFamily, String reason, double confidenceScore, bool wasEegUsed, dynamic createdAt
});




}
/// @nodoc
class __$RecommendationModelCopyWithImpl<$Res>
    implements _$RecommendationModelCopyWith<$Res> {
  __$RecommendationModelCopyWithImpl(this._self, this._then);

  final _RecommendationModel _self;
  final $Res Function(_RecommendationModel) _then;

/// Create a copy of RecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? storeId = null,Object? perfumeId = null,Object? perfumeName = null,Object? perfumeFamily = null,Object? reason = null,Object? confidenceScore = null,Object? wasEegUsed = null,Object? createdAt = freezed,}) {
  return _then(_RecommendationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,perfumeId: null == perfumeId ? _self.perfumeId : perfumeId // ignore: cast_nullable_to_non_nullable
as String,perfumeName: null == perfumeName ? _self.perfumeName : perfumeName // ignore: cast_nullable_to_non_nullable
as String,perfumeFamily: null == perfumeFamily ? _self.perfumeFamily : perfumeFamily // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,wasEegUsed: null == wasEegUsed ? _self.wasEegUsed : wasEegUsed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
