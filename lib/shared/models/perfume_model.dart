import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:perfume/core/constants/perfume_constants.dart';

part 'perfume_model.freezed.dart';
part 'perfume_model.g.dart';

@freezed
abstract class PerfumeModel with _$PerfumeModel {
  const PerfumeModel._();

  const factory PerfumeModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String brandId,
    @Default('') String brandName,
    @Default('') String description,
    @Default('') String genderTarget,
    @Default('') String family, // القيم العربية: زهري، شرقي، خشبي، منعش، سرخسي
    @Default('') String subFamily,
    @Default('معتدل') String intensityLevel,
    @Default('حلو') String sweetnessLevel,
    @Default('معتدل') String freshnessLevel,
    @Default('محايد') String warmthLevel,
    @Default(0.5) double projection,
    @Default(0.5) double longevity,
    @Default(0.5) double luxuryScore,
    @Default(<String>[]) List<String> notes,
    @Default(<String>[]) List<String> topNotes,
    @Default(<String>[]) List<String> heartNotes,
    @Default(<String>[]) List<String> baseNotes,
    @Default('') String imageUrl,
    @Default(true) bool active,
  }) = _PerfumeModel;

  factory PerfumeModel.fromJson(Map<String, dynamic> json) =>
      _$PerfumeModelFromJson(json);

  double get intensityValue =>
      PerfumeConstants.intensityLevels[intensityLevel] ?? 0.5;
  double get sweetnessValue =>
      PerfumeConstants.sweetnessLevels[sweetnessLevel] ?? 0.5;
  double get freshnessValue =>
      PerfumeConstants.freshnessLevels[freshnessLevel] ?? 0.5;
  double get warmthValue => PerfumeConstants.warmthLevels[warmthLevel] ?? 0.5;

  static const empty = PerfumeModel();
  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;
}
