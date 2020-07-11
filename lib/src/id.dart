import 'models/models.dart';
import 'transactions.dart';

class ArweaveIdApi {
  final ArweaveTransactionsApi _api;

  ArweaveIdApi(ArweaveTransactionsApi api) : _api = api;

  Future<ArweaveId> get(String address) {}

  Future<void> set(ArweaveId id, Wallet wallet) {}

  Future<String> check(String name) {}

  Future<String> getIdenticon(String name) {}
}
