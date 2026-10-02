// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'perfume_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerfumeModel {

 String get id; String get name; String get brandId; String get brandName; String get description; String get genderTarget; String get family;// القيم العربية: زهري، شرقي، خشبي، منعش، سرخسي
 String get subFamily; String get intensityLevel; String get sweetnessLevel; String get freshnessLevel; String get warmthLevel; double get projection; double get longevity; double get luxuryScore; List<String> get notes; List<String> get topNotes; List<String> get heartNotes; List<String> get baseNotes; String get imageUrl; bool get active;
/// Create a copy of PerfumeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerfumeModelCopyWith<PerfumeModel> get copyWith => _$PerfumeModelCopyWithImpl<PerfumeModel>(this as PerfumeModel, _$identity);

  /// Serializes this PerfumeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerfumeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderTarget, genderTarget) || other.genderTarget == genderTarget)&&(identical(other.family, family) || other.family == family)&&(identical(other.subFamily, subFamily) || other.subFamily == subFamily)&&(identical(other.intensityLevel, intensityLevel) || other.intensityLevel == intensityLevel)&&(identical(other.sweetnessLevel, sweetnessLevel) || other.sweetnessLevel == sweetnessLevel)&&(identical(other.freshnessLevel, freshnessLevel) || other.freshnessLevel == freshnessLevel)&&(identical(other.warmthLevel, warmthLevel) || other.warmthLevel == warmthLevel)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.longevity, longevity) || other.longevity == longevity)&&(identical(other.luxuryScore, luxuryScore) || other.luxuryScore == luxuryScore)&&const DeepCollectionEquality().equals(other.notes, notes)&&const DeepCollectionEquality().equals(other.topNotes, topNotes)&&const DeepCollectionEquality().equals(other.heartNotes, heartNotes)&&const DeepCollectionEquality().equals(other.baseNotes, baseNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,brandId,brandName,description,genderTarget,family,subFamily,intensityLevel,sweetnessLevel,freshnessLevel,warmthLevel,projection,longevity,luxuryScore,const DeepCollectionEquality().hash(notes),const DeepCollectionEquality().hash(topNotes),const DeepCollectionEquality().hash(heartNotes),const DeepCollectionEquality().hash(baseNotes),imageUrl,active]);

@override
String toString() {
  return 'PerfumeModel(id: $id, name: $name, brandId: $brandId, brandName: $brandName, description: $description, genderTarget: $genderTarget, family: $family, subFamily: $subFamily, intensityLevel: $intensityLevel, sweetnessLevel: $sweetnessLevel, freshnessLevel: $freshnessLevel, warmthLevel: $warmthLevel, projection: $projection, longevity: $longevity, luxuryScore: $luxuryScore, notes: $notes, topNotes: $topNotes, heartNotes: $heartNotes, baseNotes: $baseNotes, imageUrl: $imageUrl, active: $active)';
}


}

/// @nodoc
abstract mixin class $PerfumeModelCopyWith<$Res>  {
  factory $PerfumeModelCopyWith(PerfumeModel value, $Res Function(PerfumeModel) _then) = _$PerfumeModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brandId, String brandName, String description, String genderTarget, String family, String subFamily, String intensityLevel, String sweetnessLevel, String freshnessLevel, String warmthLevel, double projection, double longevity, double luxuryScore, List<String> notes, List<String> topNotes, List<String> heartNotes, List<String> baseNotes, String imageUrl, bool active
});




}
/// @nodoc
class _$PerfumeModelCopyWithImpl<$Res>
    implements $PerfumeModelCopyWith<$Res> {
  _$PerfumeModelCopyWithImpl(this._self, this._then);

  final PerfumeModel _self;
  final $Res Function(PerfumeModel) _then;

/// Create a copy of PerfumeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brandId = null,Object? brandName = null,Object? description = null,Object? genderTarget = null,Object? family = null,Object? subFamily = null,Object? intensityLevel = null,Object? sweetnessLevel = null,Object? freshnessLevel = null,Object? warmthLevel = null,Object? projection = null,Object? longevity = null,Object? luxuryScore = null,Object? notes = null,Object? topNotes = null,Object? heartNotes = null,Object? baseNotes = null,Object? imageUrl = null,Object? active = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderTarget: null == genderTarget ? _self.genderTarget : genderTarget // ignore: cast_nullable_to_non_nullable
as String,family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as String,subFamily: null == subFamily ? _self.subFamily : subFamily // ignore: cast_nullable_to_non_nullable
as String,intensityLevel: null == intensityLevel ? _self.intensityLevel : intensityLevel // ignore: cast_nullable_to_non_nullable
as String,sweetnessLevel: null == sweetnessLevel ? _self.sweetnessLevel : sweetnessLevel // ignore: cast_nullable_to_non_nullable
as String,freshnessLevel: null == freshnessLevel ? _self.freshnessLevel : freshnessLevel // ignore: cast_nullable_to_non_nullable
as String,warmthLevel: null == warmthLevel ? _self.warmthLevel : warmthLevel // ignore: cast_nullable_to_non_nullable
as String,projection: null == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as double,longevity: null == longevity ? _self.longevity : longevity // ignore: cast_nullable_to_non_nullable
as double,luxuryScore: null == luxuryScore ? _self.luxuryScore : luxuryScore // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,topNotes: null == topNotes ? _self.topNotes : topNotes // ignore: cast_nullable_to_non_nullable
as List<String>,heartNotes: null == heartNotes ? _self.heartNotes : heartNotes // ignore: cast_nullable_to_non_nullable
as List<String>,baseNotes: null == baseNotes ? _self.baseNotes : baseNotes // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PerfumeModel].
extension PerfumeModelPatterns on PerfumeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerfumeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerfumeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerfumeModel value)  $default,){
final _that = this;
switch (_that) {
case _PerfumeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerfumeModel value)?  $default,){
final _that = this;
switch (_that) {
case _PerfumeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brandId,  String brandName,  String description,  String genderTarget,  String family,  String subFamily,  String intensityLevel,  String sweetnessLevel,  String freshnessLevel,  String warmthLevel,  double projection,  double longevity,  double luxuryScore,  List<String> notes,  List<String> topNotes,  List<String> heartNotes,  List<String> baseNotes,  String imageUrl,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerfumeModel() when $default != null:
return $default(_that.id,_that.name,_that.brandId,_that.brandName,_that.description,_that.genderTarget,_that.family,_that.subFamily,_that.intensityLevel,_that.sweetnessLevel,_that.freshnessLevel,_that.warmthLevel,_that.projection,_that.longevity,_that.luxuryScore,_that.notes,_that.topNotes,_that.heartNotes,_that.baseNotes,_that.imageUrl,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brandId,  String brandName,  String description,  String genderTarget,  String family,  String subFamily,  String intensityLevel,  String sweetnessLevel,  String freshnessLevel,  String warmthLevel,  double projection,  double longevity,  double luxuryScore,  List<String> notes,  List<String> topNotes,  List<String> heartNotes,  List<String> baseNotes,  String imageUrl,  bool active)  $default,) {final _that = this;
switch (_that) {
case _PerfumeModel():
return $default(_that.id,_that.name,_that.brandId,_that.brandName,_that.description,_that.genderTarget,_that.family,_that.subFamily,_that.intensityLevel,_that.sweetnessLevel,_that.freshnessLevel,_that.warmthLevel,_that.projection,_that.longevity,_that.luxuryScore,_that.notes,_that.topNotes,_that.heartNotes,_that.baseNotes,_that.imageUrl,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brandId,  String brandName,  String description,  String genderTarget,  String family,  String subFamily,  String intensityLevel,  String sweetnessLevel,  String freshnessLevel,  String warmthLevel,  double projection,  double longevity,  double luxuryScore,  List<String> notes,  List<String> topNotes,  List<String> heartNotes,  List<String> baseNotes,  String imageUrl,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _PerfumeModel() when $default != null:
return $default(_that.id,_that.name,_that.brandId,_that.brandName,_that.description,_that.genderTarget,_that.family,_that.subFamily,_that.intensityLevel,_that.sweetnessLevel,_that.freshnessLevel,_that.warmthLevel,_that.projection,_that.longevity,_that.luxuryScore,_that.notes,_that.topNotes,_that.heartNotes,_that.baseNotes,_that.imageUrl,_that.active);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerfumeModel extends PerfumeModel {
  const _PerfumeModel({this.id = '', this.name = '', this.brandId = '', this.brandName = '', this.description = '', this.genderTarget = '', this.family = '', this.subFamily = '', this.intensityLevel = 'معتدل', this.sweetnessLevel = 'حلو', this.freshnessLevel = 'معتدل', this.warmthLevel = 'محايد', this.projection = 0.5, this.longevity = 0.5, this.luxuryScore = 0.5, final  List<String> notes = const <String>[], final  List<String> topNotes = const <String>[], final  List<String> heartNotes = const <String>[], final  List<String> baseNotes = const <String>[], this.imageUrl = '', this.active = true}): _notes = notes,_topNotes = topNotes,_heartNotes = heartNotes,_baseNotes = baseNotes,super._();
  factory _PerfumeModel.fromJson(Map<String, dynamic> json) => _$PerfumeModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String brandId;
@override@JsonKey() final  String brandName;
@override@JsonKey() final  String description;
@override@JsonKey() final  String genderTarget;
@override@JsonKey() final  String family;
// القيم العربية: زهري، شرقي، خشبي، منعش، سرخسي
@override@JsonKey() final  String subFamily;
@override@JsonKey() final  String intensityLevel;
@override@JsonKey() final  String sweetnessLevel;
@override@JsonKey() final  String freshnessLevel;
@override@JsonKey() final  String warmthLevel;
@override@JsonKey() final  double projection;
@override@JsonKey() final  double longevity;
@override@JsonKey() final  double luxuryScore;
 final  List<String> _notes;
@override@JsonKey() List<String> get notes {
  if (_notes is EqualUnmodifiableListView) return _notes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notes);
}

 final  List<String> _topNotes;
@override@JsonKey() List<String> get topNotes {
  if (_topNotes is EqualUnmodifiableListView) return _topNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topNotes);
}

 final  List<String> _heartNotes;
@override@JsonKey() List<String> get heartNotes {
  if (_heartNotes is EqualUnmodifiableListView) return _heartNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_heartNotes);
}

 final  List<String> _baseNotes;
@override@JsonKey() List<String> get baseNotes {
  if (_baseNotes is EqualUnmodifiableListView) return _baseNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_baseNotes);
}

@override@JsonKey() final  String imageUrl;
@override@JsonKey() final  bool active;

/// Create a copy of PerfumeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerfumeModelCopyWith<_PerfumeModel> get copyWith => __$PerfumeModelCopyWithImpl<_PerfumeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerfumeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerfumeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brandId, brandId) || other.brandId == brandId)&&(identical(other.brandName, brandName) || other.brandName == brandName)&&(identical(other.description, description) || other.description == description)&&(identical(other.genderTarget, genderTarget) || other.genderTarget == genderTarget)&&(identical(other.family, family) || other.family == family)&&(identical(other.subFamily, subFamily) || other.subFamily == subFamily)&&(identical(other.intensityLevel, intensityLevel) || other.intensityLevel == intensityLevel)&&(identical(other.sweetnessLevel, sweetnessLevel) || other.sweetnessLevel == sweetnessLevel)&&(identical(other.freshnessLevel, freshnessLevel) || other.freshnessLevel == freshnessLevel)&&(identical(other.warmthLevel, warmthLevel) || other.warmthLevel == warmthLevel)&&(identical(other.projection, projection) || other.projection == projection)&&(identical(other.longevity, longevity) || other.longevity == longevity)&&(identical(other.luxuryScore, luxuryScore) || other.luxuryScore == luxuryScore)&&const DeepCollectionEquality().equals(other._notes, _notes)&&const DeepCollectionEquality().equals(other._topNotes, _topNotes)&&const DeepCollectionEquality().equals(other._heartNotes, _heartNotes)&&const DeepCollectionEquality().equals(other._baseNotes, _baseNotes)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,brandId,brandName,description,genderTarget,family,subFamily,intensityLevel,sweetnessLevel,freshnessLevel,warmthLevel,projection,longevity,luxuryScore,const DeepCollectionEquality().hash(_notes),const DeepCollectionEquality().hash(_topNotes),const DeepCollectionEquality().hash(_heartNotes),const DeepCollectionEquality().hash(_baseNotes),imageUrl,active]);

@override
String toString() {
  return 'PerfumeModel(id: $id, name: $name, brandId: $brandId, brandName: $brandName, description: $description, genderTarget: $genderTarget, family: $family, subFamily: $subFamily, intensityLevel: $intensityLevel, sweetnessLevel: $sweetnessLevel, freshnessLevel: $freshnessLevel, warmthLevel: $warmthLevel, projection: $projection, longevity: $longevity, luxuryScore: $luxuryScore, notes: $notes, topNotes: $topNotes, heartNotes: $heartNotes, baseNotes: $baseNotes, imageUrl: $imageUrl, active: $active)';
}


}

/// @nodoc
abstract mixin class _$PerfumeModelCopyWith<$Res> implements $PerfumeModelCopyWith<$Res> {
  factory _$PerfumeModelCopyWith(_PerfumeModel value, $Res Function(_PerfumeModel) _then) = __$PerfumeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brandId, String brandName, String description, String genderTarget, String family, String subFamily, String intensityLevel, String sweetnessLevel, String freshnessLevel, String warmthLevel, double projection, double longevity, double luxuryScore, List<String> notes, List<String> topNotes, List<String> heartNotes, List<String> baseNotes, String imageUrl, bool active
});




}
/// @nodoc
class __$PerfumeModelCopyWithImpl<$Res>
    implements _$PerfumeModelCopyWith<$Res> {
  __$PerfumeModelCopyWithImpl(this._self, this._then);

  final _PerfumeModel _self;
  final $Res Function(_PerfumeModel) _then;

/// Create a copy of PerfumeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brandId = null,Object? brandName = null,Object? description = null,Object? genderTarget = null,Object? family = null,Object? subFamily = null,Object? intensityLevel = null,Object? sweetnessLevel = null,Object? freshnessLevel = null,Object? warmthLevel = null,Object? projection = null,Object? longevity = null,Object? luxuryScore = null,Object? notes = null,Object? topNotes = null,Object? heartNotes = null,Object? baseNotes = null,Object? imageUrl = null,Object? active = null,}) {
  return _then(_PerfumeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brandId: null == brandId ? _self.brandId : brandId // ignore: cast_nullable_to_non_nullable
as String,brandName: null == brandName ? _self.brandName : brandName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,genderTarget: null == genderTarget ? _self.genderTarget : genderTarget // ignore: cast_nullable_to_non_nullable
as String,family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as String,subFamily: null == subFamily ? _self.subFamily : subFamily // ignore: cast_nullable_to_non_nullable
as String,intensityLevel: null == intensityLevel ? _self.intensityLevel : intensityLevel // ignore: cast_nullable_to_non_nullable
as String,sweetnessLevel: null == sweetnessLevel ? _self.sweetnessLevel : sweetnessLevel // ignore: cast_nullable_to_non_nullable
as String,freshnessLevel: null == freshnessLevel ? _self.freshnessLevel : freshnessLevel // ignore: cast_nullable_to_non_nullable
as String,warmthLevel: null == warmthLevel ? _self.warmthLevel : warmthLevel // ignore: cast_nullable_to_non_nullable
as String,projection: null == projection ? _self.projection : projection // ignore: cast_nullable_to_non_nullable
as double,longevity: null == longevity ? _self.longevity : longevity // ignore: cast_nullable_to_non_nullable
as double,luxuryScore: null == luxuryScore ? _self.luxuryScore : luxuryScore // ignore: cast_nullable_to_non_nullable
as double,notes: null == notes ? _self._notes : notes // ignore: cast_nullable_to_non_nullable
as List<String>,topNotes: null == topNotes ? _self._topNotes : topNotes // ignore: cast_nullable_to_non_nullable
as List<String>,heartNotes: null == heartNotes ? _self._heartNotes : heartNotes // ignore: cast_nullable_to_non_nullable
as List<String>,baseNotes: null == baseNotes ? _self._baseNotes : baseNotes // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
