import 'dart:convert';

import 'package:arweave/src/models/models.dart';

import 'api/api.dart';

class ArweaveNetworkApi {
  final ArweaveApi _api;

  ArweaveNetworkApi(ArweaveApi api) : _api = api;

  Future<NetworkInfo> getInfo() => _api.get('info').then(
        (res) => NetworkInfo.fromJson(
          json.decode(res.body),
        ),
      );

  Future<List<String>> getPeers() => _api
      .get('peers')
      .then((res) => (json.decode(res.body) as List<dynamic>).cast<String>());
}
