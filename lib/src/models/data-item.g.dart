// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data-item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataItem _$DataItemFromJson(Map<String, dynamic> json) {
  return DataItem(
    owner: json['owner'] as String?,
    target: json['target'] as String?,
    nonce: json['nonce'] as String?,
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
        .toList(),
    data: json['data'] as String?,
  );
}

Map<String, dynamic> _$DataItemToJson(DataItem instance) => <String, dynamic>{
      'owner': instance.owner,
      'target': instance.target,
      'nonce': instance.nonce,
      'tags': instance.tags,
      'data': instance.data,
    };