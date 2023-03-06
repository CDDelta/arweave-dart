import 'package:json_annotation/json_annotation.dart';

part 'transaction_chunk.g.dart';

@JsonSerializable()
class TransactionChunk {
  @JsonKey(name: 'data_root')
  final String dataRoot;
  @JsonKey(name: 'data_size')
  final String dataSize;
  @JsonKey(name: 'data_path')
  final String dataPath;
  final String offset;
  final String chunk;

  TransactionChunk({
    required this.dataRoot,
    required this.dataSize,
    required this.dataPath,
    required this.offset,
    required this.chunk,
  });

  factory TransactionChunk.fromJson(Map<String, dynamic> json) =>
      _$TransactionChunkFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionChunkToJson(this);
}

@JsonSerializable()
class TransactionOffsetResponse {
  final String size;
  final String offset;

  TransactionOffsetResponse({required this.size, required this.offset});

  factory TransactionOffsetResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionOffsetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionOffsetResponseToJson(this);
}

@JsonSerializable()
class TransactionChunkResponse {
  final String chunk;
  @JsonKey(name: 'data_path')
  final String dataPath;
  @JsonKey(name: 'tx_path')
  final String txPath;

  TransactionChunkResponse(
      {required this.chunk, required this.dataPath, required this.txPath});

  factory TransactionChunkResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionChunkResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionChunkResponseToJson(this);
}
