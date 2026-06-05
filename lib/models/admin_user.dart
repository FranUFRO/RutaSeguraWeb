enum AdminUserStatus {
  active,
  pending,
  blocked,
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.rut,
    required this.primaryAddress,
    required this.organization,
    required this.status,
    required this.lastAccess,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String rut;
  final String primaryAddress;
  final String organization;
  final AdminUserStatus status;
  final DateTime lastAccess;
  final DateTime createdAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get statusLabel {
    return switch (status) {
      AdminUserStatus.active => 'Activo',
      AdminUserStatus.pending => 'Pendiente',
      AdminUserStatus.blocked => 'Bloqueado',
    };
  }

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? rut,
    String? primaryAddress,
    String? organization,
    AdminUserStatus? status,
    DateTime? lastAccess,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      rut: rut ?? this.rut,
      primaryAddress: primaryAddress ?? this.primaryAddress,
      organization: organization ?? this.organization,
      status: status ?? this.status,
      lastAccess: lastAccess ?? this.lastAccess,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
