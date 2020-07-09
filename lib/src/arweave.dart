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

  Future<Transaction> createTransaction(Map<String, String> jwk) {}

  Future<List<String>> arql(Map<String, dynamic> query) =>
      transactions.arql(query);
}
