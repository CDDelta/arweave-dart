// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data-bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataBundle _$DataBundleFromJson(Map<String, dynamic> json) {
  return DataBundle(
    items: (json['items'] as List)
        ?.map((e) =>
            e == null ? null : DataItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DataBundleToJson(DataBundle instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
