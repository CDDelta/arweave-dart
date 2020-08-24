import 'package:http/http.dart' as http;

import 'gateway_common.dart' if (dart.library.html) 'gateway_web.dart';

class ArweaveApi {
  http.Client _client;

  Uri _gatewayUrl;

  ArweaveApi({
    Uri gatewayUrl,
  })  : _gatewayUrl = gatewayUrl ?? getDefaultGateway(),
        _client = http.Client();

  Future<http.Response> get(String endpoint) =>
      _client.get(_getEndpointUrl(endpoint));

  Future<http.Response> post(String endpoint, {dynamic body}) =>
      _client.post(_getEndpointUrl(endpoint), body: body);

  String _getEndpointUrl(String endpoint) => '${_gatewayUrl.origin}/$endpoint';
}
