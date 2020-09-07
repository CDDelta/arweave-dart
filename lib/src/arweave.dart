import 'api/api.dart';
import 'id.dart';
import 'network.dart';
import 'transactions.dart';
import 'wallets.dart';

class Arweave {
  ArweaveApi get api => _api;
  ArweaveApi _api;

  ArweaveWalletsApi get wallets => _wallets;
  ArweaveWalletsApi _wallets;

  ArweaveTransactionsApi get transactions => _transactions;
  ArweaveTransactionsApi _transactions;

  ArweaveIdApi get id => _id;
  ArweaveIdApi _id;

  ArweaveNetworkApi get network => _network;
  ArweaveNetworkApi _network;

  Arweave({
    Uri gatewayUrl,
  }) {
    _api = ArweaveApi(gatewayUrl: gatewayUrl);
    _wallets = ArweaveWalletsApi(api);
    _transactions = ArweaveTransactionsApi(api);
    _id = ArweaveIdApi(transactions);
    _network = ArweaveNetworkApi(api);
  }
}
