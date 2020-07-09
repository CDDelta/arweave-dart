import 'api.dart';
import 'models/models.dart';
import 'network.dart';
import 'transactions.dart';
import 'wallets.dart';

class Arweave {
  ArweaveApi api;
  ArweaveWallets wallets;
  ArweaveTransactions transactions;
  ArweaveNetwork network;

  Arweave({ApiConfig config = null}) {
    if (config == null) config = ApiConfig();

    this.api = ArweaveApi(config: config);
    this.wallets = ArweaveWallets(api);
    this.transactions = ArweaveTransactions(api);
    this.network = ArweaveNetwork(api);
  }
}
