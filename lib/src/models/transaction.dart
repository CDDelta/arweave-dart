import '../utils.dart';
import 'tag.dart';

class Transaction {
  final int format;
  final String id;
  final String lastTx;
  final String owner;
  final List<Tag> tags;
  final String target;
  final String quantity;
  final String data;
  final String dataSize;
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
