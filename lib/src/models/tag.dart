import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  final String name;
  final String value;

  Tag(String name, String value, {bool toBase64 = true})
      : name = toBase64 ? encodeStringToBase64(name) : name,
        value = toBase64 ? encodeStringToBase64(value) : value;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
