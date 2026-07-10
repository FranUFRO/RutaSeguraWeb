enum AdminUserStatus { active, pending, blocked }

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.rut,
    required this.organization,
    required this.status,
    this.primaryAddress,
    this.lastAccess,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String rut;
  final String? primaryAddress;
  final String organization;
  final AdminUserStatus status;
  final DateTime? lastAccess;
  final DateTime? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final role = roleLabel((json['role'] ?? json['rol'] ?? '').toString());
    return AdminUser(
      id: (json['id_user'] ?? '').toString(),
      name: (json['full_name'] ?? 'Sin nombre').toString(),
      email: (json['email'] ?? json['correo'] ?? '').toString(),
      role: role,
      phone: (json['phone_number'] ?? json['telefono'] ?? '').toString(),
      rut: (json['rut'] ?? '').toString(),
      organization: (json['organizacion'] ?? 'Sin organización').toString(),
      primaryAddress: json['direccion_principal']?.toString(),
      status: statusFromApi(
        (json['status'] ?? json['account_status'] ?? '').toString(),
        role: role,
      ),
    );
  }

  static String roleLabel(String value) => switch (value.toUpperCase()) {
        'ADMIN' => 'Administrador',
        'SUPERVISOR' => 'Supervisor',
        'VOLUNTEER' => 'Voluntario',
        _ => value.isEmpty ? 'Sin rol' : value,
      };

  static String roleApi(String value) => switch (value.toLowerCase()) {
        'administrador' || 'admin' => 'ADMIN',
        'supervisor' => 'SUPERVISOR',
        _ => 'VOLUNTEER',
      };

  static AdminUserStatus statusFromApi(String value, {String? role}) {
    final normalized = value.trim().toUpperCase();
    return switch (normalized) {
      'ACTIVE' || 'ACTIVO' => AdminUserStatus.active,
      'BLOCKED' || 'BLOQUEADO' => AdminUserStatus.blocked,
      'PENDING' || 'PENDIENTE' => AdminUserStatus.pending,
      _ => role == 'Supervisor' ? AdminUserStatus.pending : AdminUserStatus.active,
    };
  }

  static String statusApi(AdminUserStatus status) => switch (status) {
        AdminUserStatus.active => 'ACTIVE',
        AdminUserStatus.pending => 'PENDING',
        AdminUserStatus.blocked => 'BLOCKED',
      };

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get statusLabel => switch (status) {
        AdminUserStatus.active => 'Activo',
        AdminUserStatus.pending => 'Pendiente',
        AdminUserStatus.blocked => 'Bloqueado',
      };
}

class AdminMetrics {
  const AdminMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.pendingUsers,
    required this.blockedUsers,
  });
  final int totalUsers;
  final int activeUsers;
  final int pendingUsers;
  final int blockedUsers;

  factory AdminMetrics.fromUsers(List<AdminUser> users) => AdminMetrics(
        totalUsers: users.length,
        activeUsers: users.where((user) => user.status == AdminUserStatus.active).length,
        pendingUsers: users.where((user) => user.status == AdminUserStatus.pending).length,
        blockedUsers: users.where((user) => user.status == AdminUserStatus.blocked).length,
      );
}
