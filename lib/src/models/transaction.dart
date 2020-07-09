import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';
import 'tag.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(defaultValue: 1)
  int format;
  final String id;
  @JsonKey(name: 'last_tx')
  final String lastTx;
  final String owner;
  final List<Tag> tags;
  final String target;
  final String quantity;
  String data;
  @JsonKey(name: 'data_size')
  final String dataSize;
  @JsonKey(name: 'data_root')
  final String dataRoot;
  final String reward;
  final String signature;

  Transaction({
    this.format,
    this.id,
    this.lastTx,
    this.owner,
    this.tags,
    this.target,
    this.quantity,
    this.data,
    this.dataSize,
    this.dataRoot,
    this.reward,
    this.signature,
  });

  void addTag(String name, String value) {
    this.tags.add(Tag(stringToBase64(name), stringToBase64(value)));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

class CreateTransactionInterface {
  final int format;
  final String lastTx;
  final String owner;
  final List<Tag> tags;
  final String target;
  final String quantity;
  final String data;
  final String dataSize;
  final String dataRoot;
  final String reward;

  CreateTransactionInterface({
    this.format,
    this.lastTx,
    this.owner,
    this.tags,
    this.target,
    this.quantity,
    this.data,
    this.dataRoot,
    this.dataSize,
    this.reward,
  }) : assert(data != null || !(target != null && quantity != null));
}
