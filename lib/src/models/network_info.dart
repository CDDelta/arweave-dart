import 'package:json_annotation/json_annotation.dart';

part 'network_info.g.dart';

@JsonSerializable()
class NetworkInfo {
  String hostNetwork;
  int version;
  int release;
  int height;
  String current;
  int blocks;
  int peers;
  int queueLength;
  int nodeStateLatency;

  NetworkInfo();

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);
}
