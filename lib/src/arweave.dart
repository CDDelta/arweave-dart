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

  Arweave({ApiConfig config = null}) {
    if (config == null) config = ApiConfig();

    this._api = ArweaveApi(config: config);
    this._wallets = ArweaveWallets(api);
    this._transactions = ArweaveTransactions(api);
    this._network = ArweaveNetwork(api);
  }

  Future<Transaction> createTransaction(
      Transaction transaction, Map<String, String> jwk) async {
    if (transaction.data != null &&
        !(transaction.target != null && transaction.quantity != null)) {
      // TODO: THrow err
    }

    if (transaction.owner == null) transaction.setOwner(jwk['n']);

    if (transaction.lastTx == null)
      transaction.setLastTx(await transactions.getTransactionAnchor());

    if (transaction.reward == null) {
      final length = transaction.data != null ? 'bytelength' : 0;
      transaction.setReward(await transactions.getPrice(
        byteSize: length,
        targetAddress: transaction.target,
      ));
    }

    return transaction;
  }

  Future<List<String>> arql(Map<String, dynamic> query) =>
      transactions.arql(query);
}
