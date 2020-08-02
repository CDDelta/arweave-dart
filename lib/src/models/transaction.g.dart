// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    format: json['format'] as int ?? 1,
    id: json['id'] as String,
    lastTx: json['last_tx'] as String,
    owner: json['owner'] as String,
    tags: (json['tags'] as List)
        ?.map((e) => e == null ? null : Tag.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    target: json['target'] as String,
    quantity: json['quantity'] as String,
    data: json['data'] as String,
    dataSize: json['data_size'] as String,
    reward: json['reward'] as String,
    signature: json['signature'] as String,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'format': instance.format,
      'id': instance.id,
      'last_tx': instance.lastTx,
      'owner': instance.owner,
      'tags': instance.tags,
      'target': instance.target,
      'quantity': instance.quantity,
      'data': instance.data,
      'data_size': instance.dataSize,
      'reward': instance.reward,
      'signature': instance.signature,
    };
