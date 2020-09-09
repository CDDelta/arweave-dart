// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionChunk _$TransactionChunkFromJson(Map<String, dynamic> json) {
  return TransactionChunk(
    dataRoot: json['data_root'] as String,
    dataSize: json['data_size'] as String,
    dataPath: json['data_path'] as String,
    offset: json['offset'] as String,
    chunk: json['chunk'] as String,
  );
}

Map<String, dynamic> _$TransactionChunkToJson(TransactionChunk instance) =>
    <String, dynamic>{
      'data_root': instance.dataRoot,
      'data_size': instance.dataSize,
      'data_path': instance.dataPath,
      'offset': instance.offset,
      'chunk': instance.chunk,
    };

TransactionOffsetResponse _$TransactionOffsetResponseFromJson(
    Map<String, dynamic> json) {
  return TransactionOffsetResponse(
    size: json['size'] as String,
    offset: json['offset'] as String,
  );
}

Map<String, dynamic> _$TransactionOffsetResponseToJson(
        TransactionOffsetResponse instance) =>
    <String, dynamic>{
      'size': instance.size,
      'offset': instance.offset,
    };

TransactionChunkResponse _$TransactionChunkResponseFromJson(
    Map<String, dynamic> json) {
  return TransactionChunkResponse(
    chunk: json['chunk'] as String,
    dataPath: json['data_path'] as String,
    txPath: json['tx_path'] as String,
  );
}

Map<String, dynamic> _$TransactionChunkResponseToJson(
        TransactionChunkResponse instance) =>
    <String, dynamic>{
      'chunk': instance.chunk,
      'data_path': instance.dataPath,
      'tx_path': instance.txPath,
    };
