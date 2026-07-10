import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });

  final String id;
  final String email;
  final String role;
  final String? name;

  String get displayName {
    final cleanName = name?.trim();
    if (cleanName != null && cleanName.isNotEmpty) return cleanName;
    return email.isEmpty ? 'Administrador' : email;
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final source = json['data'] is Map ? Map<String, dynamic>.from(json['data'] as Map) : json;
    return AuthUser(
      id: (source['id_user'] ?? '').toString(),
      email: (source['email'] ?? '').toString(),
      role: (source['role'] ?? source['rol'] ?? '').toString().toUpperCase(),
      name: (source['full_name'] ?? source['name'] ?? source['nombre_completo'])?.toString(),
    );
  }
}

class AuthService extends ChangeNotifier {
  AuthService(this._api);
  final ApiClient _api;
  AuthUser? user;
  bool get isAuthenticated => user != null && user!.role == 'ADMIN';
  String get adminId => user?.id ?? '';

  Future<void> restore() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('auth_token');
    final id = preferences.getString('auth_user_id');
    final role = preferences.getString('auth_role');
    final email = preferences.getString('auth_email') ?? '';
    final name = preferences.getString('auth_name');
    if (token != null && id != null && role == 'ADMIN' && !_isExpired(token)) {
      _api.bearerToken = token;
      user = AuthUser(id: id, email: email, role: role!, name: name);
      await refreshProfile(notify: false);
    } else {
      await _clearPersisted();
      user = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, bool rememberSession) async {
    final response = await _api.post('/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final token = response['token']?.toString();
    if (token == null || token.isEmpty) {
      throw const ApiException('El servidor no entrego un token de acceso.');
    }
    _api.bearerToken = token;
    final loggedIn = AuthUser(
      id: (response['id_user'] ?? '').toString(),
      email: email.trim().toLowerCase(),
      role: (response['rol'] ?? '').toString().toUpperCase(),
      name: (response['full_name'] ?? response['name'] ?? response['nombre_completo'])?.toString(),
    );
    if (loggedIn.role != 'ADMIN') {
      expire();
      throw const ApiException('Esta cuenta no tiene permisos de administrador.', statusCode: 403);
    }
    user = loggedIn;
    await refreshProfile(notify: false);
    if (rememberSession) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('auth_token', token);
      await _persistUser(user ?? loggedIn);
    } else {
      await _clearPersisted();
    }
    notifyListeners();
  }

  Future<void> refreshProfile({bool notify = true}) async {
    final current = user;
    if (current == null) return;

    try {
      final response = await _api.get('/profile');
      final profile = AuthUser.fromJson(response);
      user = AuthUser(
        id: profile.id.isNotEmpty ? profile.id : current.id,
        email: profile.email.isNotEmpty ? profile.email : current.email,
        role: profile.role.isNotEmpty ? profile.role : current.role,
        name: profile.name ?? current.name,
      );
      await _persistUser(user!);
      if (notify) notifyListeners();
    } catch (_) {
      if (notify) notifyListeners();
    }
  }

  Future<void> logout() async {
    await _clearPersisted();
    expire();
  }

  void expire() {
    user = null;
    _api.bearerToken = null;
    SharedPreferences.getInstance().then((preferences) {
      preferences.remove('auth_token');
      preferences.remove('auth_user_id');
      preferences.remove('auth_role');
      preferences.remove('auth_email');
      preferences.remove('auth_name');
    });
    notifyListeners();
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final expiration = payload['exp'] as num?;
      return expiration == null || DateTime.now().millisecondsSinceEpoch >= expiration * 1000;
    } catch (_) {
      return true;
    }
  }

  Future<void> _clearPersisted() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove('auth_token'),
      preferences.remove('auth_user_id'),
      preferences.remove('auth_role'),
      preferences.remove('auth_email'),
      preferences.remove('auth_name'),
    ]);
  }

  Future<void> _persistUser(AuthUser user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('auth_user_id', user.id);
    await preferences.setString('auth_role', user.role);
    await preferences.setString('auth_email', user.email);
    final name = user.name?.trim();
    if (name == null || name.isEmpty) {
      await preferences.remove('auth_name');
    } else {
      await preferences.setString('auth_name', name);
    }
  }
}
