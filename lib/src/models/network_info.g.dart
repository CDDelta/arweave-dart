// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) {
  return NetworkInfo(
    hostNetwork: json['hosnetworkt'] as String,
    version: json['version'] as int,
    release: json['release'] as int,
    height: json['height'] as int,
    current: json['current'] as String,
    blocks: json['blocks'] as int,
    peers: json['peers'] as int,
    queueLength: json['queue_length'] as int,
    nodeStateLatency: json['node_state_latency'] as int,
  );
}

Map<String, dynamic> _$NetworkInfoToJson(NetworkInfo instance) =>
    <String, dynamic>{
      'hosnetworkt': instance.hostNetwork,
      'version': instance.version,
      'release': instance.release,
      'height': instance.height,
      'current': instance.current,
      'blocks': instance.blocks,
      'peers': instance.peers,
      'queue_length': instance.queueLength,
      'node_state_latency': instance.nodeStateLatency,
    };
