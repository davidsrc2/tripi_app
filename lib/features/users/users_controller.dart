// lib/features/users/users_controller.dart
import 'package:flutter/foundation.dart';
import '../../data/tripi_api.dart';

class UsersController extends ChangeNotifier {
  final TripiApi _api;

  UsersController(this._api);

  bool loading = false;
  String? error;

  Map<String, dynamic>? me;
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> followers = [];
  List<Map<String, dynamic>> following = [];

  Future<void> loadMe() async {
    await _run(() async {
      me = await _api.me();
    });
  }

  Future<void> updateMe(Map<String, dynamic> payload) async {
    await _run(() async {
      me = await _api.updateMe(payload);
    });
  }

  Future<void> loadUserById(int userId) async {
    await _run(() async {
      userProfile = await _api.getUserById(userId);
    });
  }

  Future<void> follow(int userId) async {
    await _run(() async {
      await _api.followUser(userId);
    });
  }

  Future<void> unfollow(int userId) async {
    await _run(() async {
      await _api.unfollowUser(userId);
    });
  }

  Future<void> loadFollowers(int userId, {int skip = 0, int limit = 100}) async {
    await _run(() async {
      followers = await _api.getUserFollowers(userId, skip: skip, limit: limit);
    });
  }

  Future<void> loadFollowing(int userId, {int skip = 0, int limit = 100}) async {
    await _run(() async {
      following = await _api.getUserFollowing(userId, skip: skip, limit: limit);
    });
  }

  Future<void> uploadAvatar(String path) async {
    await _run(() async {
      me = await _api.uploadProfilePicture(filePath: path);
    });
  }

  // ---- helper de estado ----
  Future<void> _run(Future<void> Function() block) async {
    try {
      loading = true;
      error = null;
      notifyListeners();
      await block();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
