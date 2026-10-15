import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Catatan pembayaran yang sudah dikirim tetapi jawabannya belum pasti
/// (timeout / koneksi putus / app mati di tengah request). Disimpan di storage
/// supaya kasir diminta memverifikasi folio sebelum membayar ulang.
class PendingPayment {
  static const String _key = "pendingPayments";

  static Future<List<Map<String, dynamic>>> _readAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _writeAll(List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (items.isEmpty) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, jsonEncode(items));
      }
    } catch (_) {}
  }

  /// Dipanggil SEBELUM request pembayaran dikirim.
  static Future<void> mark(
      int captainOrderId, String accountName, num amount) async {
    final items = await _readAll();
    items.removeWhere((e) => e["coId"] == captainOrderId);
    items.add({
      "coId": captainOrderId,
      "account": accountName,
      "amount": amount,
      "at": DateTime.now().toIso8601String(),
    });
    await _writeAll(items);
  }

  /// Dipanggil saat server memberi jawaban pasti (sukses atau ditolak).
  static Future<void> clear(int captainOrderId) async {
    final items = await _readAll();
    items.removeWhere((e) => e["coId"] == captainOrderId);
    await _writeAll(items);
  }

  /// Mengembalikan catatan pending untuk captain order ini (atau null).
  static Future<Map<String, dynamic>?> find(int captainOrderId) async {
    final items = await _readAll();
    for (final e in items) {
      if (e["coId"] == captainOrderId) return e;
    }
    return null;
  }
}
