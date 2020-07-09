import 'package:json_annotation/json_annotation.dart';

part 'network_info.g.dart';

@JsonSerializable()
class NetworkInfo {
  @JsonKey(name: 'hosnetworkt')
  final String hostNetwork;
  final int version;
  final int release;
  final int height;
  final String current;
  final int blocks;
  final int peers;
  @JsonKey(name: 'queue_length')
  final int queueLength;
  @JsonKey(name: 'node_state_latency')
  final int nodeStateLatency;

  NetworkInfo({
    this.hostNetwork,
    this.version,
    this.release,
    this.height,
    this.current,
    this.blocks,
    this.peers,
    this.queueLength,
    this.nodeStateLatency,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);
}
