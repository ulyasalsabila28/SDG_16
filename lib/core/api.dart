import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const kBgImage =
    'https://pmb.univpancasila.ac.id/wp-content/uploads/2025/06/Pancasila-Pengertian-Sejarah-Filosofi-dan-Fakta-Uniknya-4-scaled.jpg';

const statusLabel = {'belum': 'Belum Diverifikasi', 'sedang': 'Sedang Diverifikasi', 'selesai': 'Sudah Ditangani'};
Color statusColor(String s) => s == 'belum' ? Colors.red : (s == 'sedang' ? Colors.amber : Colors.green);

class ApiError implements Exception {
  final String message;
  final bool needOtp;
  final String? devOtp;
  ApiError(this.message, {this.needOtp = false, this.devOtp});
  @override
  String toString() => message;
}

class Api {
  static const _custom = String.fromEnvironment('API_URL');
  static String get url {
    if (_custom.isNotEmpty) return _custom;
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return android ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
  }

  static String? token;
  static final reportsChanged = ValueNotifier<int>(0);
  static final tab = ValueNotifier<int>(0);

  static Future<void> loadSession() async {
    token = (await SharedPreferences.getInstance()).getString('token');
  }

  static Future<void> saveSession(String? t) async {
    token = t;
    final p = await SharedPreferences.getInstance();
    t == null ? await p.remove('token') : await p.setString('token', t);
  }

  static Future<dynamic> call(String method, String path, {Map<String, dynamic>? body}) async {
    final req = http.Request(method, Uri.parse('$url$path'));
    req.headers['Content-Type'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (body != null) req.body = jsonEncode(body);
    http.Response res;
    try {
      res = await http.Response.fromStream(await req.send().timeout(const Duration(seconds: 10)));
    } catch (_) {
      throw ApiError('Tidak dapat terhubung ke server ($url). Pastikan backend sudah berjalan.');
    }
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw ApiError(data?['error'] ?? 'Terjadi kesalahan', needOtp: data?['needOtp'] == true, devOtp: data?['devOtp']);
    }
    return data;
  }

  static Future<dynamic> get(String p) => call('GET', p);
  static Future<dynamic> post(String p, Map<String, dynamic> b) => call('POST', p, body: b);
  static Future<dynamic> put(String p, Map<String, dynamic> b) => call('PUT', p, body: b);

  static Future<void> logout() => saveSession(null);
}

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(m)));
