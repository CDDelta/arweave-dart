import 'dart:html';

import 'gateway_common.dart' as common;

Uri getDefaultGateway() {
  if (window == null || window.location == null) {
    return common.getDefaultGateway();
  }

  final isLocal =
      ['localhost', '127.0.0.1'].contains(window.location.hostname) ||
          window.location.protocol == 'file:';
  if (isLocal) return common.getDefaultGateway();

  return Uri.parse(window.location.origin);
}
