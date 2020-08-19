import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/export.dart';

import '../utils.dart';
import 'tag.dart';
import 'wallet.dart';

part 'transaction.g.dart';

String _bigIntToString(BigInt v) => v.toString();
BigInt _stringToBigInt(String v) => BigInt.parse(v);

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

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get quantity => _quantity;
  BigInt _quantity;

  String get data => _data;
  String _data;

  @JsonKey(name: 'data_size')
  String get dataSize => _dataSize;
  String _dataSize;

  @JsonKey(fromJson: _stringToBigInt, toJson: _bigIntToString)
  BigInt get reward => _reward;
  BigInt _reward;

  String get signature => _signature;
  String _signature;

  Transaction({
    int format = 1,
    String id,
    String lastTx,
    String owner,
    List<Tag> tags,
    String target = "",
    BigInt quantity,
    String data = "",
    List<int> dataBytes,
    String dataSize = "0",
    String dataRoot,
    BigInt reward,
    String signature,
  })  : _format = format,
        _id = id,
        _lastTx = lastTx,
        _owner = owner,
        _tags = tags,
        _target = target,
        _quantity = quantity ?? BigInt.zero,
        _data = data,
        _dataSize = dataSize,
        _reward = reward ?? BigInt.zero,
        _signature = signature,
        assert(!(data.isNotEmpty && dataBytes != null)) {
    if (dataSize == "0") {
      if (data.isNotEmpty)
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
    _dataSize = ascii.encode(_data).length.toString();
  }

  void setDataWithBytes(List<int> bytes) {
    _data = encodeBytesToBase64(bytes);
    _dataSize = bytes.length.toString();
  }

  void setReward(BigInt reward) => _reward = reward;

  void setSignature(String signature, String id) {
    this._signature = signature;
    this._id = id;
  }

  Future<List<int>> getSignatureData() async {
    switch (format) {
      case 1:
        var buffer = decodeBase64ToBytes(owner) +
            decodeBase64ToBytes(target) +
            decodeBase64ToBytes(data) +
            utf8.encode(quantity.toString()) +
            utf8.encode(reward.toString()) +
            decodeBase64ToBytes(lastTx) +
            tags
                .expand((t) =>
                    decodeBase64ToBytes(t.name) + decodeBase64ToBytes(t.value))
                .toList();

        return Uint8List.fromList(buffer);
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

  Future<void> sign(Wallet wallet) async {
    final signatureData = await getSignatureData();
    final rawSignature = wallet.sign(signatureData);

    final id = encodeBytesToBase64(sha256.convert(rawSignature.bytes).bytes);

    setSignature(encodeBytesToBase64(rawSignature.bytes), id);
  }

  Future<bool> verify() async {
    final signatureData = await getSignatureData();
    final claimedRawSignature = decodeBase64ToBytes(signature);

    final expectedId =
        encodeBytesToBase64(sha256.convert(claimedRawSignature).bytes);

    if (id != expectedId) return false;

    var signer = PSSSigner(RSAEngine(), SHA256Digest(), SHA256Digest())
      ..init(
        false,
        ParametersWithSalt(
          PublicKeyParameter<RSAPublicKey>(
            RSAPublicKey(
              decodeBase64ToBigInt(owner),
              publicExponent,
            ),
          ),
          null,
        ),
      );

    return signer.verifySignature(
        signatureData, PSSSignature(claimedRawSignature));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
