import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sales/utils/mutation_guard.dart';
import 'package:point_of_sales/utils/pending_payment.dart';
import 'package:point_of_sales/utils/request.dart';
import 'package:point_of_sales/utils/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MutationGuard', () {
    test('menolak eksekusi ganda dengan kunci sama', () async {
      final gate = Completer<int>();
      var calls = 0;
      final first = MutationGuard.run('k', () {
        calls++;
        return gate.future;
      });
      final second = await MutationGuard.run('k', () async {
        calls++;
        return 2;
      });
      expect(second, isNull);
      expect(MutationGuard.isRunning('k'), isTrue);
      gate.complete(1);
      expect(await first, 1);
      expect(calls, 1);
      expect(MutationGuard.isRunning('k'), isFalse);
    });

    test('kunci dilepas saat job melempar error', () async {
      await expectLater(
          MutationGuard.run('e', () async => throw StateError('x')),
          throwsStateError);
      expect(MutationGuard.isRunning('e'), isFalse);
      expect(await MutationGuard.run('e', () async => 7), 7);
    });

    test('kunci berbeda berjalan bersamaan', () async {
      final gate = Completer<void>();
      final a = MutationGuard.run('a', () => gate.future);
      expect(await MutationGuard.run('b', () async => 1), 1);
      gate.complete();
      await a;
    });
  });

  group('PendingPayment', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('mark, find, clear', () async {
      expect(await PendingPayment.find(10), isNull);
      await PendingPayment.mark(10, 'CASH', 50000);
      final p = await PendingPayment.find(10);
      expect(p?['account'], 'CASH');
      expect(p?['amount'], 50000);
      expect(await PendingPayment.find(11), isNull);
      await PendingPayment.clear(10);
      expect(await PendingPayment.find(10), isNull);
    });

    test('mark ulang mengganti catatan lama', () async {
      await PendingPayment.mark(1, 'A', 1);
      await PendingPayment.mark(1, 'B', 2);
      expect((await PendingPayment.find(1))?['account'], 'B');
    });
  });

  group('Request.isUncertain', () {
    test('timeout dan network error dianggap tidak pasti', () {
      expect(Request.isUncertain(http.Response('{}', kStatusTimeout)), isTrue);
      expect(
          Request.isUncertain(http.Response('{}', kStatusNetworkError)), isTrue);
      expect(Request.isUncertain(null), isTrue);
    });

    test('respons server biasa dianggap pasti', () {
      expect(Request.isUncertain(http.Response('{}', 200)), isFalse);
      expect(Request.isUncertain(http.Response('{}', 400)), isFalse);
    });
  });

  group('LoginLockout', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('terkunci setelah batas kegagalan lalu bisa direset', () async {
      for (var i = 0; i < LoginLockout.maxFailures - 1; i++) {
        await LoginLockout.recordFailure();
        expect(await LoginLockout.remaining(), isNull);
      }
      await LoginLockout.recordFailure();
      final left = await LoginLockout.remaining();
      expect(left, isNotNull);
      expect(left! <= LoginLockout.lockDuration, isTrue);
      await LoginLockout.reset();
      expect(await LoginLockout.remaining(), isNull);
    });

    test('kunci yang sudah lewat dibersihkan', () async {
      SharedPreferences.setMockInitialValues({
        'loginFailures': 5,
        'loginLockedUntil':
            DateTime.now().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
      });
      expect(await LoginLockout.remaining(), isNull);
    });
  });

  group('ServerConfig', () {
    test('skema mengikuti pengaturan HTTPS', () async {
      SharedPreferences.setMockInitialValues(
          {'host': '10.0.0.5', 'port': '8080'});
      expect(await ServerConfig.baseUrl(), 'http://10.0.0.5:8080/');
      SharedPreferences.setMockInitialValues(
          {'host': 'srv', 'port': '443', 'useHttps': true});
      expect(await ServerConfig.baseUrl(), 'https://srv:443/');
      expect(await ServerConfig.baseUrl(portOverride: '9000'),
          'https://srv:9000/');
    });
  });
}
