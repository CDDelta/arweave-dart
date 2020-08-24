import 'api/api.dart';
import 'id.dart';
import 'models/models.dart';
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

  Future<Transaction> createTransaction(
    Transaction transaction,
    Wallet wallet,
  ) async {
    assert(transaction.data != null ||
        (transaction.target != null && transaction.quantity != null));

    if (transaction.owner == null) transaction.setOwner(wallet.owner);

    if (transaction.lastTx == null)
      transaction.setLastTx(await transactions.getTransactionAnchor());

    if (transaction.reward == BigInt.zero && transaction.data.isNotEmpty)
      transaction.setReward(await transactions.getPrice(
        byteSize: int.parse(transaction.dataSize),
        targetAddress: transaction.target,
      ));

    return transaction;
  }

  Future<List<String>> arql(Map<String, dynamic> query) =>
      transactions.arql(query);
}
