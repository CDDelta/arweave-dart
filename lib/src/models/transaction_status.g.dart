// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionStatus _$TransactionStatusFromJson(Map<String, dynamic> json) {
  return TransactionStatus(
    status: json['status'] as int,
    confirmed: json['confirmed'] == null
        ? null
        : TransactionConfimedData.fromJson(
            json['confirmed'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$TransactionStatusToJson(TransactionStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'confirmed': instance.confirmed,
    };

TransactionConfimedData _$TransactionConfimedDataFromJson(
    Map<String, dynamic> json) {
  return TransactionConfimedData(
    blockIndepHash: json['block_indep_hash'] as String,
    blockHeight: json['block_height'] as int,
    numberOfConfirmations: json['number_of_confirmations'] as int,
  );
}

Map<String, dynamic> _$TransactionConfimedDataToJson(
        TransactionConfimedData instance) =>
    <String, dynamic>{
      'block_indep_hash': instance.blockIndepHash,
      'block_height': instance.blockHeight,
      'number_of_confirmations': instance.numberOfConfirmations,
    };
