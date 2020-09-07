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
    quantity: _stringToBigInt(json['quantity'] as String),
    data: json['data'] as String,
    dataSize: json['data_size'] as String,
    dataRoot: json['data_root'] as String,
    reward: _stringToBigInt(json['reward'] as String),
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
      'quantity': _bigIntToString(instance.quantity),
      'data': instance.data,
      'data_size': instance.dataSize,
      'data_root': instance.dataRoot,
      'reward': _bigIntToString(instance.reward),
      'signature': instance.signature,
    };
