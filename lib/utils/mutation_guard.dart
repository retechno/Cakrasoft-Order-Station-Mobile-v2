import 'dart:async';

/// Mencegah operasi mutasi yang sama berjalan dua kali bersamaan
/// (double-tap, tap saat request belum selesai). Server menerima duplikat,
/// jadi pencegahan harus di client.
///
/// ```dart
/// final result = await MutationGuard.run('co:$id:discount', () => _discount());
/// if (result == null) { /* sedang berjalan, abaikan */ }
/// ```
class MutationGuard {
  static final Set<String> _running = <String>{};

  static bool isRunning(String key) => _running.contains(key);

  /// Menjalankan [job]. Mengembalikan null bila [key] masih berjalan.
  /// Kunci selalu dilepas (try/finally), termasuk saat [job] melempar error.
  static Future<T?> run<T>(String key, Future<T> Function() job) async {
    if (_running.contains(key)) return null;
    _running.add(key);
    try {
      return await job();
    } finally {
      _running.remove(key);
    }
  }
}
