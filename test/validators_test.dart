import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:point_of_sales/models/product_model.dart';
import 'package:point_of_sales/screens/pages/config/config_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigController validators', () {
    late ConfigController c;
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      Get.reset();
      c = ConfigController();
    });

    test('hostname valid', () {
      for (final h in ['127.0.0.1', 'server', 'my-host.local', 'a.b.c']) {
        expect(c.hostValidator(h), isNull, reason: h);
      }
    });

    test('hostname tidak valid', () {
      for (final h in ['', ' ', '-bad', 'bad-', 'a b', 'a_b', 'a..b', 'a/b']) {
        expect(c.hostValidator(h), isNotNull, reason: h);
      }
    });

    test('port', () {
      expect(c.portValidator('8080'), isNull);
      expect(c.portValidator('65535'), isNull);
      expect(c.portValidator('0'), isNotNull);
      expect(c.portValidator('65536'), isNotNull);
      expect(c.portValidator('abc'), isNotNull);
    });
  });

  group('Products.fromJson', () {
    test('toleran terhadap field null dan harga int/double', () {
      final p = Products.fromJson({'Code': 'P1', 'Name': 'Nasi', 'Price': 12});
      expect(p.code, 'P1');
      expect(p.productName, 'Nasi');
      expect(p.price, 12);
      final q = Products.fromJson({'Price': 12.5});
      expect(q.code, '');
      expect(q.price, 12.5);
    });
  });
}
