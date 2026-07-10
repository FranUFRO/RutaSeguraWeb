import 'dart:typed_data';

import '../models/admin_user.dart';
import 'api_client.dart';
import 'auth_service.dart';

class AdminUserService {
  const AdminUserService(this._api, this._auth);
  final ApiClient _api;
  final AuthService _auth;

  String get _adminId => _auth.adminId;

  Future<List<AdminUser>> getUsers() async {
    final response = await _api.get('/$_adminId/users/all');
    return (response['users'] as List? ?? const [])
        .map((item) => AdminUser.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<AdminUser> getUserById(String id) async {
    final response = await _api.get('/$_adminId/users/$id/details');
    return AdminUser.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/$_adminId/users/$id/delete');
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String rut,
    required String phone,
    required String organization,
    required String role,
    Uint8List? certificateBytes,
    String? certificateName,
  }) async {
    await _api.multipart('/$_adminId/user/create', {
      'nombre_completo': name.trim(),
      'correo_electronico': email.trim().toLowerCase(),
      'password': password,
      'rut': rut.trim(),
      'telefono': phone.trim(),
      'organizacion': organization.trim(),
      'rol': AdminUser.roleApi(role),
    }, fileBytes: certificateBytes, fileName: certificateName);
  }

  Future<void> updateUser(AdminUser user) async {
    await _api.patch('/$_adminId/users/${user.id}/edit', {
      'new_name': user.name.trim(),
      'phone_number': user.phone.trim(),
      'organizacion': user.organization.trim(),
      'role': AdminUser.roleApi(user.role),
    });
  }
}
