import 'dart:typed_data';

import 'models.dart';

abstract class TransactionBase {
  String get id;

  //Null owner means the transaction hasnt been prepared
  String? get owner;

  List<Tag> get tags;

  String get target;

  Uint8List get data;

  //Null signature means the transaction hasnt been signed
  String? get signature;

  void setOwner(String owner);

  void addTag(String name, String value);

  /// Returns the message that should be signed to produce a valid signature.
  Future<Uint8List> getSignatureData();

  Future<void> sign(Wallet wallet);
  Future<void> signWithRawSignature(Uint8List rawSignature);

  Future<bool> verify();
}
