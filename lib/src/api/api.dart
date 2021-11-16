import 'package:http/http.dart' as http;

import 'gateway_common.dart' if (dart.library.html) 'gateway_web.dart';

class ArweaveApi {
  final Uri gatewayUrl;

  final http.Client _client;

  ArweaveApi({
    Uri? gatewayUrl,
  })  : gatewayUrl = gatewayUrl ?? getDefaultGateway(),
        _client = http.Client();

  Future<http.Response> get(String endpoint) =>
      _client.get(_getEndpointUri(endpoint));

  Future<http.Response> post(String endpoint, {dynamic body}) =>
      _client.post(_getEndpointUri(endpoint), body: body);

  Uri _getEndpointUri(String endpoint) =>
      Uri.parse('${gatewayUrl.origin}/$endpoint');
}
