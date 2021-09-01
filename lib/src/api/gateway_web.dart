import 'dart:html';

import 'gateway_common.dart' as common;

Uri getDefaultGateway() {
  try {
    return common.getDefaultGateway();
  } catch (e) {
    final isLocal =
        ['localhost', '127.0.0.1'].contains(window.location.hostname) ||
            window.location.protocol == 'file:';
    if (isLocal) return common.getDefaultGateway();

    return Uri.parse(window.location.origin);
  }
}
