import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/store.dart';
import '../services/api_service.dart';
import '../services/http_api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  static const _keyToken = 'access_token';
  static const _keyRefresh = 'refresh_token';

  AuthStatus _status = AuthStatus.unknown;
  UserDto? _user;
  StoreDto? _store;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserDto? get user => _user;
  StoreDto? get store => _store;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.unknown;

  final ApiService _api;

  AuthProvider(this._api) {
    _wireTokenRefresh();
    _tryRestoreSession();
  }

  /// Khi interceptor refresh token thành công → lưu lại; khi hết hạn hẳn → logout.
  void _wireTokenRefresh() {
    final api = _api;
    if (api is HttpApiService) {
      api.onTokensRefreshed = (access, refresh) {
        _saveTokens(access, refresh);
      };
      api.onAuthExpired = () {
        logout();
      };
    }
  }

  Future<void> _tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final refresh = prefs.getString(_keyRefresh);
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    (_api as HttpApiService).setToken(token);
    (_api as HttpApiService).setRefreshToken(refresh);
    try {
      try {
        _store = await _api.getMyStore();
      } catch (_) {
        _store = null;
      }
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _clearTokens();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final res = await _api.login(email, password);
      await _saveTokens(res.accessToken, res.refreshToken);
      (_api as HttpApiService).setToken(res.accessToken);
      (_api as HttpApiService).setRefreshToken(res.refreshToken);
      _user = res.user;
      try {
        _store = await _api.getMyStore();
      } catch (_) {
        _store = null;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _errorMessage = null;
    try {
      final res = await _api.register(email, password, name);
      await _saveTokens(res.accessToken, res.refreshToken);
      (_api as HttpApiService).setToken(res.accessToken);
      (_api as HttpApiService).setRefreshToken(res.refreshToken);
      _user = res.user;
      try {
        _store = await _api.getMyStore();
      } catch (_) {
        _store = null;
      }
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật hồ sơ (tên/email). Trả true nếu thành công, cập nhật _user.
  Future<bool> updateProfile({String? name, String? email}) async {
    _errorMessage = null;
    try {
      final updated = await _api.updateProfile(name: name, email: email);
      _user = updated;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      _errorMessage = (msg.contains('409') || msg.contains('Conflict'))
          ? 'Email đã được dùng bởi tài khoản khác'
          : _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Đổi mật khẩu. Trả true nếu thành công.
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    _errorMessage = null;
    try {
      await _api.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      final msg = e.toString();
      _errorMessage = (msg.contains('401') || msg.contains('Unauthorized'))
          ? 'Mật khẩu hiện tại không đúng'
          : _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearTokens();
    (_api as HttpApiService).clearToken();
    _user = null;
    _store = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, access);
    await prefs.setString(_keyRefresh, refresh);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefresh);
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('401') || msg.contains('Unauthorized')) {
      return 'Email hoặc mật khẩu không đúng';
    }
    if (msg.contains('409') || msg.contains('Conflict')) {
      return 'Email này đã được đăng ký';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Không kết nối được server';
    }
    return 'Có lỗi xảy ra, thử lại sau';
  }
}
