import 'api.dart';
import 'models/models.dart';
import 'network.dart';
import 'transactions.dart';
import 'wallets.dart';

class Arweave {
  ArweaveApi get api => _api;
  ArweaveApi _api;

  ArweaveWallets get wallets => _wallets;
  ArweaveWallets _wallets;

  ArweaveTransactions get transactions => _transactions;
  ArweaveTransactions _transactions;

  ArweaveNetwork get network => _network;
  ArweaveNetwork _network;

  Arweave({
    String host,
    String protocol,
    int port,
  }) {
    this._api = ArweaveApi(host: host, protocol: protocol, port: port);
    this._wallets = ArweaveWallets(api);
    this._transactions = ArweaveTransactions(api);
    this._network = ArweaveNetwork(api);
  }

  Future<Transaction> createTransaction(
      Transaction transaction, Wallet wallet) async {
    assert(transaction.data != null &&
        !(transaction.target != null && transaction.quantity != null));

    throw UnimplementedError();

    if (transaction.owner == null) transaction.setOwner(wallet.owner);

    if (transaction.lastTx == null)
      transaction.setLastTx(await transactions.getTransactionAnchor());

    if (transaction.reward == null)
      transaction.setReward(await transactions.getPrice(
        byteSize: int.parse(transaction.dataSize),
        targetAddress: transaction.target,
      ));

    return transaction;
  }

  Future<List<String>> arql(Map<String, dynamic> query) =>
      transactions.arql(query);
}
