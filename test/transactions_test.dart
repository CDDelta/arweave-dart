import 'package:arweave/arweave.dart';
import 'package:test/test.dart';

import 'utils.dart';

const liveDataTxId = "bNbA3TEQVL60xlgCcqdz4ZPHFZ711cZ3hmkpGttDt_U";

void main() {
  Arweave client;

  setUp(() {
    client = getArweaveClient();
  });

  test('get transaction data', () async {
    final txRawData = await client.transactions.getData(liveDataTxId);
    expect(txRawData, contains("CjwhRE9DVFlQRSBodG1sPgo"));
  });
}
