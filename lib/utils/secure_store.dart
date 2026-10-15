import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan token sesi. Token disimpan di Android Keystore
/// (flutter_secure_storage), bukan SharedPreferences yang berupa plaintext.
class TokenStore {
  static const String _key = "token";
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String> read() async {
    try {
      final v = await _storage.read(key: _key);
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {
      // keystore tidak tersedia: lanjut ke migrasi/fallback
    }
    return _migrateLegacy();
  }

  static Future<void> write(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {}
    await _removeLegacy();
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
    await _removeLegacy();
  }

  /// Token lama (versi sebelumnya) di SharedPreferences dipindahkan sekali.
  static Future<String> _migrateLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(_key) ?? "";
      if (legacy.isNotEmpty) {
        await _storage.write(key: _key, value: legacy);
        await prefs.remove(_key);
      }
      return legacy;
    } catch (_) {
      return "";
    }
  }

  static Future<void> _removeLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}

/// Alamat server. Skema http/https dipilih di layar konfigurasi.
class ServerConfig {
  static Future<String> baseUrl({String? portOverride}) async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString("host") ?? "";
    var port = prefs.getString("port") ?? "";
    if (portOverride != null && portOverride.isNotEmpty) port = portOverride;
    final scheme = (prefs.getBool("useHttps") ?? false) ? "https" : "http";
    return '$scheme://$host:$port/';
  }
}

/// Pembatasan percobaan login. Disimpan agar tidak hilang saat app ditutup.
/// Catatan: ini hanya pengaman sisi client; lockout sebenarnya harus di server.
class LoginLockout {
  static const int maxFailures = 5;
  static const Duration lockDuration = Duration(minutes: 5);
  static const String _failKey = "loginFailures";
  static const String _untilKey = "loginLockedUntil";

  /// Sisa waktu terkunci, atau null bila tidak terkunci.
  static Future<Duration?> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_untilKey) ?? 0;
    final left = until - DateTime.now().millisecondsSinceEpoch;
    if (left <= 0) {
      if (until != 0) {
        await prefs.remove(_untilKey);
        await prefs.remove(_failKey);
      }
      return null;
    }
    return Duration(milliseconds: left);
  }

  static Future<void> recordFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getInt(_failKey) ?? 0) + 1;
    if (n >= maxFailures) {
      await prefs.setInt(
          _untilKey,
          DateTime.now().add(lockDuration).millisecondsSinceEpoch);
      await prefs.setInt(_failKey, n);
    } else {
      await prefs.setInt(_failKey, n);
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failKey);
    await prefs.remove(_untilKey);
  }
}
