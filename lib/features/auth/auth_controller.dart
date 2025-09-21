// lib/features/auth/auth_controller.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config.dart';
import '../../data/auth_repository.dart';
import '../../data/tripi_api.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _auth;
  final TripiApi _api;

  bool loading = false;
  String? error;

  AuthController(this._auth, this._api);

  Future<void> signUpAndRegisterBO({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    try {
      // 1) Alta en Firebase (quedará logado)
      await _auth.signUpEmail(email, password);

      // 2) UID + log de baseUrl para verificar entorno/emulador
      final uid = FirebaseAuth.instance.currentUser!.uid;
      debugPrint('BaseUrl actual -> ${AppConfig.baseUrl}');
      debugPrint('Firebase UID -> $uid');

      // 3) Registro en tu BO (snake_case)
      await _api.registerInBO(
        firebaseUid: uid,
        username: username,
        email: email,
        nickname: username,
      );

      error = null;
    } on DioException catch (e) {
      // Logs precisos de request/response
      final uri = e.requestOptions.uri;
      final headers = Map.of(e.requestOptions.headers)..remove('Authorization');
      debugPrint('❌ registerInBO falló');
      debugPrint('URL llamada -> $uri');
      debugPrint('Headers enviados -> $headers');
      debugPrint('Body enviado -> ${e.requestOptions.data}');
      debugPrint('Status -> ${e.response?.statusCode}');
      debugPrint('Respuesta -> ${e.response?.data}');

      error = 'API ${e.response?.statusCode ?? '-'}: ${e.response?.data ?? e.message}';
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInEmail(email, password);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInGoogle() async {
    _setLoading(true);
    try {
      await _auth.signInGoogle();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }
}
