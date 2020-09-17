import 'api/api.dart';
import 'chunks.dart';
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

  ArweaveNetworkApi get network => _network;
  ArweaveNetworkApi _network;

  ArweaveChunksApi get chunks => _chunks;
  ArweaveChunksApi _chunks;

  Arweave({
    Uri gatewayUrl,
  }) {
    _api = ArweaveApi(gatewayUrl: gatewayUrl);
    _wallets = ArweaveWalletsApi(api);
    _transactions = ArweaveTransactionsApi(api);
    _network = ArweaveNetworkApi(api);
    _chunks = ArweaveChunksApi(api);
  }
}
