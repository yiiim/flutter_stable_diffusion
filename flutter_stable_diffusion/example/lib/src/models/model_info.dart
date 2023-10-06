import 'package:json_annotation/json_annotation.dart';

part 'model_info.g.dart';

@JsonSerializable()
class ModelInfo {
  final String id;
  final String url;

  ModelInfo({
    required this.id,
    required this.url,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) => _$ModelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ModelInfoToJson(this);
}
