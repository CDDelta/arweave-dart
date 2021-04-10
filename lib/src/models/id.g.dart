// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArweaveId _$ArweaveIdFromJson(Map<String, dynamic> json) {
  return ArweaveId(
    name: json['name'] as String?,
    url: json['url'] as String?,
    text: json['text'] as String?,
    avatarDataUri: json['avatarDataUri'] as String?,
  );
}

Map<String, dynamic> _$ArweaveIdToJson(ArweaveId instance) => <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'text': instance.text,
      'avatarDataUri': instance.avatarDataUri,
    };
