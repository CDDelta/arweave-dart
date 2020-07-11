import 'dart:convert';

import 'package:crypto/crypto.dart';
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

  String get reward => _reward;
  String _reward;

  String get signature => _signature;
  String _signature;

  Transaction({
    int format = 1,
    String id,
    String lastTx,
    String owner,
    List<Tag> tags,
    String target,
    String quantity,
    String data,
    List<int> dataBytes,
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
        _reward = reward,
        _signature = signature,
        assert(!(data != null && dataBytes != null)) {
    if (dataSize == null) {
      if (data != null)
        setData(data);
      else if (dataBytes != null) setDataWithBytes(dataBytes);
    }

    if (_tags == null) _tags = [];
    ;
  }

  void setLastTx(String lastTx) => _lastTx = lastTx;

  void setOwner(String owner) => _owner = owner;

  void setData(String data) {
    _data = encodeStringToBase64(data);
    _dataSize = utf8.encode(_data).length.toString();
  }

  void setDataWithBytes(List<int> bytes) {
    _data = encodeBytesToBase64(bytes);
    _dataSize = bytes.length.toString();
  }

  void setReward(String reward) => _reward = reward;

  void setSignature(String signature, String id) {
    this._signature = signature;
    this._id = id;
  }

  Future<List<int>> getSignatureData() async {
    switch (format) {
      case 1:
        final buffers = <Iterable<int>>[
          decodeBase64ToBytes(owner),
          if (target != null) decodeBase64ToBytes(target),
          if (data != null) decodeBase64ToBytes(data),
          utf8.encode(quantity.toString()),
          utf8.encode(reward.toString()),
          decodeBase64ToBytes(lastTx),
          tags
              .expand((t) => [
                    decodeBase64ToBytes(t.name),
                    decodeBase64ToBytes(t.value),
                  ])
              .expand((t) => t),
        ];

        return sha256.convert(buffers.expand((b) => b).toList()).bytes;
      case 2:
        throw UnimplementedError(
            'Transaction format 2 is currently unsupported.');
      default:
        throw Exception('Unexpected transaction format!');
    }
  }

  void addTag(String name, String value) {
    this.tags.add(Tag(encodeStringToBase64(name), encodeStringToBase64(value)));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
