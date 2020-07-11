import 'package:json_annotation/json_annotation.dart';

part 'id.g.dart';

@JsonSerializable()
class ArweaveId {
  String name;
  String url;
  String text;
  String avatarDataUri;

  ArweaveId({this.name, this.url, this.text, this.avatarDataUri});

  factory ArweaveId.fromJson(Map<String, dynamic> json) =>
      _$ArweaveIdFromJson(json);
  Map<String, dynamic> toJson() => _$ArweaveIdToJson(this);
}
