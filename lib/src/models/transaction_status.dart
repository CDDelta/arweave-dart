import 'package:json_annotation/json_annotation.dart';

part 'transaction_status.g.dart';

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
