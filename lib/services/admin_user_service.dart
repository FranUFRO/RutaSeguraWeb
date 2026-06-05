import '../models/admin_user.dart';
import '../models/supervisor_verification.dart';

class AdminUserService {
  const AdminUserService();

  List<AdminUser> getUsers() {
    return [
      AdminUser(
        id: 'USR-001',
        name: 'Valentina Rojas',
        email: 'valentina.rojas@rutasegura.com',
        role: 'Administrador',
        phone: '+56 9 6123 4567',
        rut: '18.456.210-4',
        primaryAddress: 'Av. Providencia 1208, Santiago',
        organization: 'Ruta Segura Central',
        status: AdminUserStatus.active,
        lastAccess: DateTime(2026, 5, 23, 18, 20),
        createdAt: DateTime(2026, 2, 12),
      ),
      AdminUser(
        id: 'USR-002',
        name: 'Diego Mendez',
        email: 'diego.mendez@rutasegura.com',
        role: 'Supervisor',
        phone: '+56 9 7123 9876',
        rut: '17.992.340-1',
        primaryAddress: 'Los Pimientos 442, Antofagasta',
        organization: 'Operaciones Norte',
        status: AdminUserStatus.pending,
        lastAccess: DateTime(2026, 5, 21, 9, 45),
        createdAt: DateTime(2026, 3, 4),
      ),
      AdminUser(
        id: 'USR-003',
        name: 'Camila Torres',
        email: 'camila.torres@rutasegura.com',
        role: 'Voluntario',
        phone: '+56 9 8456 1200',
        rut: '19.104.782-8',
        primaryAddress: 'Calle Las Rosas 87, La Florida',
        organization: 'Rutas Escolares',
        status: AdminUserStatus.active,
        lastAccess: DateTime(2026, 5, 24, 8, 10),
        createdAt: DateTime(2026, 1, 28),
      ),
      AdminUser(
        id: 'USR-004',
        name: 'Matias Silva',
        email: 'matias.silva@rutasegura.com',
        role: 'Voluntario',
        phone: '+56 9 5345 9901',
        rut: '20.301.445-2',
        primaryAddress: 'Pasaje Los Aromos 155, Valparaiso',
        organization: 'Soporte Comunitario',
        status: AdminUserStatus.blocked,
        lastAccess: DateTime(2026, 5, 11, 14, 30),
        createdAt: DateTime(2025, 12, 18),
      ),
    ];
  }

  AdminUser getUserById(String id) {
    return getUsers().firstWhere(
      (user) => user.id == id,
      orElse: () => getUsers().first,
    );
  }

  AdminMetrics getMetrics() {
    final users = getUsers();
    return AdminMetrics(
      totalUsers: users.length,
      activeUsers: users.where((user) => user.status == AdminUserStatus.active).length,
      pendingUsers: users.where((user) => user.status == AdminUserStatus.pending).length,
      blockedUsers: users.where((user) => user.status == AdminUserStatus.blocked).length,
    );
  }

  List<SupervisorVerification> getPendingSupervisorVerifications() {
    return [
      SupervisorVerification(
        id: 'SUP-001',
        name: 'Diego Mendez',
        email: 'diego.mendez@rutasegura.com',
        phone: '+56 9 7123 9876',
        rut: '17.992.340-1',
        organization: 'Operaciones Norte',
        location: 'Antofagasta',
        submittedAt: DateTime(2026, 5, 28, 11, 30),
        documents: [
          VerificationDocument(
            id: 'DOC-001',
            title: 'Certificado de personalidad juridica',
            fileName: 'certificado_personalidad_juridica_operaciones_norte.pdf',
            pageCount: 4,
            status: DocumentReviewStatus.pending,
          ),
        ],
      ),
      SupervisorVerification(
        id: 'SUP-002',
        name: 'Mariana Jara',
        email: 'mariana.jara@rutasegura.com',
        phone: '+56 9 6412 3009',
        rut: '16.421.900-7',
        organization: 'Brigada Escolar Sur',
        location: 'Concepcion',
        submittedAt: DateTime(2026, 5, 29, 15, 5),
        documents: [
          VerificationDocument(
            id: 'DOC-002',
            title: 'Certificado de personalidad juridica',
            fileName: 'certificado_personalidad_juridica_brigada_escolar_sur.pdf',
            pageCount: 5,
            status: DocumentReviewStatus.pending,
          ),
        ],
      ),
      SupervisorVerification(
        id: 'SUP-003',
        name: 'Sebastian Kwan',
        email: 'sebastian.kwan@rutasegura.com',
        phone: '+56 9 8120 4431',
        rut: '15.884.211-K',
        organization: 'Red Comunitaria Oriente',
        location: 'Santiago',
        submittedAt: DateTime(2026, 5, 30, 9, 20),
        documents: [
          VerificationDocument(
            id: 'DOC-003',
            title: 'Certificado de personalidad juridica',
            fileName: 'certificado_personalidad_juridica_red_oriente.pdf',
            pageCount: 6,
            status: DocumentReviewStatus.pending,
          ),
        ],
      ),
    ];
  }
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
}
