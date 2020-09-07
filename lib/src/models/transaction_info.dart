import 'package:json_annotation/json_annotation.dart';

part 'transaction_info.g.dart';

@JsonSerializable()
class TransactionStatus {
  final int status;
  final TransactionConfimedData confirmed;

  TransactionStatus({this.status, this.confirmed});

  factory TransactionStatus.fromJson(Map<String, dynamic> json) =>
      _$TransactionStatusFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionStatusToJson(this);
}

@JsonSerializable()
class TransactionConfimedData {
  @JsonKey(name: 'block_indep_hash')
  final String blockIndepHash;
  @JsonKey(name: 'block_height')
  final int blockHeight;
  @JsonKey(name: 'number_of_confirmations')
  final int numberOfConfirmations;

  TransactionConfimedData(
      {this.blockIndepHash, this.blockHeight, this.numberOfConfirmations});

  factory TransactionConfimedData.fromJson(Map<String, dynamic> json) =>
      _$TransactionConfimedDataFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionConfimedDataToJson(this);
}

@JsonSerializable()
class TransactionOffsetResponse {
  final String size;
  final String offset;

  TransactionOffsetResponse({this.size, this.offset});

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

  TransactionChunkResponse({this.chunk, this.dataPath, this.txPath});

  factory TransactionChunkResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionChunkResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionChunkResponseToJson(this);
}
