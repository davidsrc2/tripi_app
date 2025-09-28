// lib/data/tripi_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

enum MediaTypeHint { auto, jpeg, png, webp }



class TripiApi {
  final Dio _dio;

  TripiApi()
      : _dio = Dio(
          BaseOptions(
            // ⚠️ AppConfig.baseUrl debe TERMINAR en /api/v1/
            baseUrl: AppConfig.baseUrl,
            headers: const {
              'Accept': 'application/json',
            },
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ) {
    // Interceptor para adjuntar el idToken de Firebase como Bearer
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final idToken = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $idToken';
            } else {
              options.headers.remove('Authorization');
            }
          } catch (_) {
            // en caso de fallo al obtener token, seguimos sin header
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (kDebugMode) {
            debugPrint('[TripiApi] Error: ${e.requestOptions.method} ${e.requestOptions.uri}');
            debugPrint(' -> ${e.response?.statusCode} ${e.response?.data}');
          }
          return handler.next(e);
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

  // ---------- Helpers ----------
  T _ensureMap<T>(dynamic data) {
    if (data is T) return data;
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is T) return decoded as T;
    }
    throw Exception('Respuesta inesperada: ${data.runtimeType}');
  }

  List<Map<String, dynamic>> _ensureListOfMap(dynamic data) {
    if (data is List) {
      return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        return decoded
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }
    throw Exception('Respuesta inesperada (lista): ${data.runtimeType}');
  }

  // ---------- USERS ----------
  /// GET /api/v1/users/me
  Future<Map<String, dynamic>> me() async {
    final r = await _dio.get('users/me'); // sin slash inicial
    return _ensureMap<Map<String, dynamic>>(r.data);
  }

  /// PUT /api/v1/users/me
  /// [payload] debe seguir tu esquema UserUpdate (p.ej. { "username": "...", "bio": "...", ... })
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> payload) async {
    final r = await _dio.put('users/me', data: payload);
    return _ensureMap<Map<String, dynamic>>(r.data);
  }

  /// GET /api/v1/users/{user_id}
  Future<Map<String, dynamic>> getUserById(int userId) async {
    final r = await _dio.get('users/$userId');
    return _ensureMap<Map<String, dynamic>>(r.data);
  }

  /// POST /api/v1/users/{user_id}/follow  (204)
  Future<void> followUser(int userId) async {
    await _dio.post('users/$userId/follow');
  }

  /// DELETE /api/v1/users/{user_id}/follow  (204)
  Future<void> unfollowUser(int userId) async {
    await _dio.delete('users/$userId/follow');
  }

  /// GET /api/v1/users/{user_id}/followers?skip=&limit=
  Future<List<Map<String, dynamic>>> getUserFollowers(
    int userId, {
    int skip = 0,
    int limit = 100,
  }) async {
    final r = await _dio.get(
      'users/$userId/followers',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return _ensureListOfMap(r.data);
  }

  /// GET /api/v1/users/{user_id}/following?skip=&limit=
  Future<List<Map<String, dynamic>>> getUserFollowing(
    int userId, {
    int skip = 0,
    int limit = 100,
  }) async {
    final r = await _dio.get(
      'users/$userId/following',
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return _ensureListOfMap(r.data);
  }

  /// POST /api/v1/users/me/profile-picture  (multipart/form-data)
  /// Sube una imagen y devuelve el UserResponse actualizado.
  Future<Map<String, dynamic>> uploadProfilePicture({
    required String filePath,
    String fieldName = 'file', // coincide con tu OpenAPI
    String? filename,
    MediaTypeHint hint = MediaTypeHint.auto,
  }) async {
    final name = filename ?? filePath.split(Platform.pathSeparator).last;
    final contentType = _guessContentType(name, hint);

    final form = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(
        filePath,
        filename: name,
        contentType: contentType, // requiere dio ^5
      ),
    });

    final r = await _dio.post(
      'users/me/profile-picture',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _ensureMap<Map<String, dynamic>>(r.data);
  }

  // ---------- Util ----------
  /// Deducción simple del content-type de imagen
MediaType _guessContentType(String filename, MediaTypeHint hint) {
  final f = filename.toLowerCase();
  if (hint == MediaTypeHint.jpeg || f.endsWith('.jpg') || f.endsWith('.jpeg')) {
    return MediaType('image', 'jpeg');
  }
  if (hint == MediaTypeHint.png || f.endsWith('.png')) {
    return MediaType('image', 'png');
  }
  if (hint == MediaTypeHint.webp || f.endsWith('.webp')) {
    return MediaType('image', 'webp');
  }
  // por defecto
  return MediaType('image', 'jpeg');
}

}




