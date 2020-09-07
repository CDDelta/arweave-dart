// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_info.dart';

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
