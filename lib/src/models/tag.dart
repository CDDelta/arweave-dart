import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  /// The tag's name encoded as Base64.
  final String name;

  /// The tag's value encoded as Base64.
  final String value;

  Tag(this.name, this.value);

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(o) => o is Tag && name == o.name && value == o.value;
}
