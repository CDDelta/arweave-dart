// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionStream _$TransactionStreamFromJson(Map<String, dynamic> json) =>
    TransactionStream(
      format: json['format'] as int? ?? 1,
      id: json['id'] as String?,
      lastTx: json['last_tx'] as String?,
      owner: json['owner'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
      target: json['target'] as String?,
      quantity: _stringToBigInt(json['quantity'] as String),
      dataSize: json['data_size'] as String?,
      dataRoot: json['data_root'] as String?,
      reward: _stringToBigInt(json['reward'] as String),
      signature: json['signature'] as String?,
    );

Map<String, dynamic> _$TransactionStreamToJson(TransactionStream instance) =>
    <String, dynamic>{
      'format': instance.format,
      'id': instance.id,
      'last_tx': instance.lastTx,
      'owner': instance.owner,
      'tags': instance.tags,
      'target': instance.target,
      'quantity': _bigIntToString(instance.quantity),
      'data_size': instance.dataSize,
      'data_root': instance.dataRoot,
      'reward': _bigIntToString(instance.reward),
      'signature': instance.signature,
    };
