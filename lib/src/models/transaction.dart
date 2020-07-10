import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

import '../utils.dart';
import 'tag.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(defaultValue: 1)
  int get format => _format;
  int _format;

  String get id => _id;
  String _id;

  @JsonKey(name: 'last_tx')
  String get lastTx => _lastTx;
  String _lastTx;

  String get owner => _owner;
  String _owner;

  List<Tag> get tags => _tags;
  List<Tag> _tags;

  String get target => _target;
  String _target;

  String get quantity => _quantity;
  String _quantity;

  String get data => _data;
  String _data;

  @JsonKey(name: 'data_size')
  String get dataSize => _dataSize;
  String _dataSize;

  @JsonKey(name: 'data_root')
  String get dataRoot => _dataRoot;
  String _dataRoot;

  String get reward => _reward;
  String _reward;

  String get signature => _signature;
  String _signature;

  Transaction({
    int format,
    String id,
    String lastTx,
    String owner,
    List<Tag> tags,
    String target,
    String quantity,
    String data,
    String dataSize,
    String dataRoot,
    String reward,
    String signature,
  })  : _format = format,
        _id = id,
        _lastTx = lastTx,
        _owner = owner,
        _tags = tags,
        _target = target,
        _quantity = quantity,
        _data = data,
        _dataSize = dataSize,
        _dataRoot = dataRoot,
        _reward = reward,
        _signature = signature {
    if (data != null && (dataSize == null || dataRoot == null)) setData(data);
  }

  void setLastTx(String lastTx) => _lastTx = lastTx;

  void setOwner(String owner) => _owner = owner;

  void setData(String data, {bool computeDataDetails = true}) {}

  void setReward(String reward) => _reward = reward;

  void setSignature(String signature, String id) {
    this._signature = signature;
    this._id = id;
  }

  Future<Uint8List> getSignatureData() {}

  void addTag(String name, String value) {
    this.tags.add(Tag(stringToBase64(name), stringToBase64(value)));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
