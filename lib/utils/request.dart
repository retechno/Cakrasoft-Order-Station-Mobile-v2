import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:point_of_sales/utils/secure_store.dart';

/// Status sintetis (bukan dari server) untuk kegagalan di sisi client.
/// Hasil request dengan status ini TIDAK PASTI: server mungkin sudah
/// memproses permintaan. Jangan dianggap gagal-aman untuk operasi uang.
const int kStatusTimeout = 598;
const int kStatusNetworkError = 599;

/// Client HTTP ke server POS.
///
/// - Tidak pernah mengembalikan `null` dan tidak melempar error jaringan.
///   Kegagalan jaringan dikembalikan sebagai [http.Response] sintetis dengan
///   status [kStatusTimeout]/[kStatusNetworkError] dan body JSON
///   `{"StatusCode": <status>, "Message": "...", "Result": null}`, sehingga
///   kode pemanggil yang mem-parse body non-200 tetap aman.
/// - Tidak melakukan retry otomatis (server menerima duplikat).
/// - Hanya 401 yang mengarahkan ke /login. Tidak ada navigasi lain di sini.
class Request {
  static const Duration readTimeout = Duration(seconds: 15);
  static const Duration writeTimeout = Duration(seconds: 30);

  final String url;
  final dynamic body;
  String portX;

  static DateTime? _lastNotice;

  Request({required this.url, this.body, this.portX = ""});

  /// True bila hasil request tidak pasti (jaringan/timeout), bukan jawaban server.
  static bool isUncertain(http.Response? response) {
    return response == null ||
        response.statusCode == kStatusTimeout ||
        response.statusCode == kStatusNetworkError;
  }

  Future<http.Response> post() => _send('POST', writeTimeout);

  Future<http.Response> get() => _send('GET', readTimeout);

  Future<http.Response> put() => _send('PUT', writeTimeout);

  Future<http.Response> _send(String method, Duration timeout) async {
    try {
      final String token = await TokenStore.read();
      final uri =
          Uri.parse('${await ServerConfig.baseUrl(portOverride: portX)}$url');
      final headers = {"token": token};

      if (kDebugMode) {
        print("$method: $uri");
      }

      late final http.Response res;
      switch (method) {
        case 'POST':
          res = await http
              .post(uri, body: body, headers: headers)
              .timeout(timeout);
          break;
        case 'PUT':
          res =
              await http.put(uri, body: body, headers: headers).timeout(timeout);
          break;
        default:
          res = await http.get(uri, headers: headers).timeout(timeout);
      }

      if (res.statusCode == 401 && portX == "") {
        if (Get.currentRoute != "/login") {
          Get.offAllNamed("/login");
        }
      }
      return res;
    } on TimeoutException {
      return _failure(kStatusTimeout,
          "Server tidak merespons (timeout). Status permintaan belum diketahui.");
    } on SocketException {
      return _failure(kStatusNetworkError,
          "Tidak dapat terhubung ke server. Periksa WiFi dan pengaturan server.");
    } catch (e) {
      if (kDebugMode) {
        print("request error: $e");
      }
      return _failure(kStatusNetworkError, "Terjadi kesalahan koneksi.");
    }
  }

  http.Response _failure(int status, String message) {
    // Printer service (portX) menangani pesannya sendiri.
    if (portX == "") {
      _notify(message);
    }
    return http.Response(
        jsonEncode({"StatusCode": status, "Message": message, "Result": null}),
        status,
        headers: {"content-type": "application/json; charset=utf-8"});
  }

  /// Snackbar ringan (dibatasi 1x per 4 detik) agar kegagalan tidak senyap.
  static void _notify(String message) {
    final now = DateTime.now();
    if (_lastNotice != null &&
        now.difference(_lastNotice!) < const Duration(seconds: 4)) {
      return;
    }
    _lastNotice = now;
    try {
      Get.snackbar("Connection", message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
    } catch (_) {
      // belum ada overlay (mis. saat startup): abaikan
    }
  }

  /// Dipakai splash/config. Melempar error jaringan agar pemanggil bisa
  /// membedakan "server tidak terjangkau".
  Future<http.Response> testConnection() async {
    final urlBase = await ServerConfig.baseUrl();

    if (kDebugMode) {
      print("get:$urlBase$url");
    }
    return http
        .get(Uri.parse(urlBase + url))
        .timeout(const Duration(seconds: 10));
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}
