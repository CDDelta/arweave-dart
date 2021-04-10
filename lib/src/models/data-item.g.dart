// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data-item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataItem _$DataItemFromJson(Map<String, dynamic> json) {
  return DataItem(
    id: json['id'] as String?,
    owner: json['owner'] as String?,
    target: json['target'] as String?,
    nonce: json['nonce'] as String?,
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
        .toList(),
    data: json['data'] as String?,
    signature: json['signature'] as String?,
  );
}

Map<String, dynamic> _$DataItemToJson(DataItem instance) => <String, dynamic>{
      'id': instance.id,
      'owner': instance.owner,
      'target': instance.target,
      'nonce': instance.nonce,
      'tags': instance.tags,
      'data': instance.data,
      'signature': instance.signature,
    };
