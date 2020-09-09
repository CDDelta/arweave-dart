// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_uploader.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SerializedTransactionUploader _$SerializedTransactionUploaderFromJson(
    Map<String, dynamic> json) {
  return SerializedTransactionUploader(
    chunkIndex: json['chunkIndex'] as int,
    txPosted: json['txPosted'] as bool,
    transaction: json['transaction'] == null
        ? null
        : Transaction.fromJson(json['transaction'] as Map<String, dynamic>),
    lastRequestTimeEnd: json['lastRequestTimeEnd'] as int,
    lastResponseStatus: json['lastResponseStatus'] as int,
    lastResponseError: json['lastResponseError'] as String,
  );
}

Map<String, dynamic> _$SerializedTransactionUploaderToJson(
        SerializedTransactionUploader instance) =>
    <String, dynamic>{
      'chunkIndex': instance.chunkIndex,
      'txPosted': instance.txPosted,
      'transaction': instance.transaction,
      'lastRequestTimeEnd': instance.lastRequestTimeEnd,
      'lastResponseStatus': instance.lastResponseStatus,
      'lastResponseError': instance.lastResponseError,
    };
