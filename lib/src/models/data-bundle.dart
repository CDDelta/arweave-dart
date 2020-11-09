import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'data-bundle.g.dart';

@JsonSerializable()
class DataBundle {
  final List<DataItem> items;

  DataBundle({this.items});

  factory DataBundle.fromJson(Map<String, dynamic> json) =>
      _$DataBundleFromJson(json);
  Map<String, dynamic> toJson() => _$DataBundleToJson(this);
}
