import 'package:arweave/src/api/sandbox.dart';
import 'package:arweave/src/utils.dart';
import 'package:test/test.dart';

typedef SandboxDomain = String;
typedef TxId = String;
void main() async {
  group('Utils:', () {
    test('longTo8ByteArray', () async {
      var long = 9;
      expect(longTo8ByteArray(long), [9, 0, 0, 0, 0, 0, 0, 0]);
    });
    test('Sandbox Domain Generation test', () {
      Map<SandboxDomain, TxId> testBaseline = {
        'f3valm4d36fd6w4uhuibvjrnwra3entolqiojhlcsghhnp32pstq':
            'LuoFs4Pfij9blD0QGqYttEGyNm5cEOSdYpGOdr96fKc',
        'flqlektwzxrgtlpmce53dnnej2clq5njgbbh2tztjbs4aqz3owjq':
            'KuCyKnbN4mmt7BE7sbWkToS4dakwQn1PM0hlwEM7dZM',
        '6c6fodlctydufzmbsmzykkweigtk5w5zrqauiyetmcaqukgm':
            '8LxXDWKeB_0LlgZMzhSrEQaau27-mMAURgk2CBCijMY',
        'oerew5mrlsda5yrsmml3vwpxb6tvpobbzyfb4l5pucthyyhmbe':
            'cSJLdZFchg7iMmMXutn3D6dXuCHOCh4_vr6CmfGDsCc',
        'vxxdwy6scapybz7ekkw32ua5naseioagnu4uutbq3cftvivl':
            're47Y9IQH4-Dn5FKtvVAdaCRE-OAZtOUpMMNiLOqKrw',
        'bujjxactpuy7cmm3ul6fjuwuqnbymloddqvsjswhxsvkd255bq':
            'DRKbgFN9MfExm6L8VNLUg0OGLcMcKyTKx7yq_oeu9DM',
        'b4zy2sx2upeczfaxpscxfuglgh2mljo4gu6ycuhujgz5yjbc':
            'DzONSvqjyCyUF3yFctDLMfTFpd_w-1PYFQ9Emz3CQic',
        'kruhyqr3j24gxknxda2pbqa6ru2ctocctwr4z3hesnjukreb':
            'VGh8QjtOuGuptxg08MAejTQpuEKdo8zs_5JNTRUSB_Q',
      };

      testBaseline.forEach((key, value) async {
        final subdomain = toB32(fromB64Url(value));
        if (key == subdomain) {
          print('Test success for $value');
        } else {
          print('Test failed for $value. expected $key got $subdomain');
        }
      });
      testBaseline.forEach(
          (key, value) => expect(key, equals(toB32(fromB64Url(value)))));
    });
  });
}
