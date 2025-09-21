// lib/data/tripi_api.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';

class TripiApi {
  final Dio _dio;

  TripiApi()
      : _dio = Dio(
          BaseOptions(
            // ⚠️ AppConfig.baseUrl debe TERMINAR en /api/v1/
            baseUrl: AppConfig.baseUrl,
            headers: const {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    // Log completo (request/response)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    // Añade (si hay sesión) el ID Token de Firebase y traza URL/headers/body
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final idToken =
              await FirebaseAuth.instance.currentUser?.getIdToken(true);
          if (idToken != null) {
            o.headers['Authorization'] = 'Bearer $idToken';
          }
          final headersSinAuth = Map.of(o.headers)..remove('Authorization');
          debugPrint('➡️ ${o.method} ${o.uri}');
          debugPrint('   Headers: $headersSinAuth');
          if (o.data != null) debugPrint('   Body: ${o.data}');
          h.next(o);
        },
        onResponse: (r, h) {
          debugPrint('✅ [${r.statusCode}] ${r.requestOptions.uri}');
          h.next(r);
        },
        onError: (e, h) {
          debugPrint('❌ [${e.response?.statusCode}] ${e.requestOptions.uri}');
          debugPrint('   Resp: ${e.response?.data}');
          h.next(e);
        },
      ),
    );
  }

  /// POST /api/v1/auth/register
  /// Body en snake_case, JSON real.
  Future<void> registerInBO({
    required String firebaseUid,
    required String username,
    required String email,
    String? nickname,
  }) async {
    final body = <String, dynamic>{
      'firebase_uid': firebaseUid,           // <- snake_case
      'username': username,
      'email': email,
      'nickname': nickname ?? username,
    };

    // Log explícito del JSON que enviamos
    debugPrint('🧾 JSON: ${jsonEncode(body)}');

    // ¡OJO! Path SIN “/” inicial para no romper el baseUrl (/api/v1/)
    await _dio.post('auth/register', data: body);
    // Si el BO devuelve 4xx/5xx, Dio lanzará DioException (lo capturas en el controller).
  }

  /// GET /api/v1/users/me
  Future<Map<String, dynamic>> me() async {
    final r = await _dio.get('users/me'); // sin “/” inicial
    if (r.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(r.data);
    }
    if (r.data is String) {
      return Map<String, dynamic>.from(jsonDecode(r.data as String));
    }
    throw Exception('Respuesta inesperada en /users/me: ${r.data.runtimeType}');
  }
}



