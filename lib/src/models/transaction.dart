import 'dart:convert';
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

  @JsonKey(ignore: true)
  Uint8List get dataBuffer => _dataBuffer;
  Uint8List _dataBuffer;

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
    Uint8List dataBuffer,
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
        _signature = signature,
        assert(!(data != null && dataBuffer != null)) {
    if (dataSize == null || dataRoot == null) {
      if (data != null)
        setData(data);
      else if (dataBuffer != null) setDataWithBuffer(dataBuffer);
    }
  }

  void setLastTx(String lastTx) => _lastTx = lastTx;

  void setOwner(String owner) => _owner = owner;

  /// Sets the data on the transaction and recalculates the `dataRoot` and `dataSize`.
  void setData(String data) {
    _data = data;
    _dataSize = utf8.encode(data).length.toString();
  }

  /// Encodes the buffer as base64 on the transaction and recalculates the `dataRoot` and `dataSize`.
  void setDataWithBuffer(Uint8List buffer) {
    _data = encodeBytesToBase64(buffer);
    _dataBuffer = buffer;
    _dataSize = buffer.length.toString();
  }

  void setReward(String reward) => _reward = reward;

  void setSignature(String signature, String id) {
    this._signature = signature;
    this._id = id;
  }

  Future<Uint8List> getSignatureData() {
    switch (format) {
      case 1:
        throw UnimplementedError(
            'Getting signature data for transaction format 1 is currently unimplemented.');
      case 2:
        final buffers = <Uint8List>[];

        buffers.addAll([
          utf8.encode(format.toString()),
          decodeBase64ToBytes(owner),
          decodeBase64ToBytes(target),
          utf8.encode(quantity.toString()),
          utf8.encode(reward.toString()),
          decodeBase64ToBytes(lastTx),
        ]);

        buffers.addAll(tags.expand((t) => [
              decodeBase64ToBytes(t.name),
              decodeBase64ToBytes(t.value),
            ]));

        buffers.addAll([
          utf8.encode(dataSize),
          decodeBase64ToBytes(dataRoot),
        ]);

        return null;
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
