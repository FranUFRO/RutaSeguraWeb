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
        primaryAddress: 'Av. Providencia 1208, Temuco',
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
        primaryAddress: 'Los Pimientos 442, Temuco',
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
        primaryAddress: 'Calle Las Rosas 87, Temuco',
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
        primaryAddress: 'Pasaje Los Aromos 155, Temuco',
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
      sosAlerts: 5, // Simulación de alertas SOS activas
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
        location: 'Temuco',
        submittedAt: DateTime(2026, 5, 28, 11, 30),
        documents: [
          VerificationDocument(
            id: 'DOC-001',
            title: 'Certificado de personalidad jurídica',
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
        location: 'Temuco',
        submittedAt: DateTime(2026, 5, 29, 15, 5),
        documents: [
          VerificationDocument(
            id: 'DOC-002',
            title: 'Certificado de personalidad jurídica',
            fileName: 'certificado_personalidad_juridica_brigada_escolar_sur.pdf',
            pageCount: 5,
            status: DocumentReviewStatus.pending,
          ),
        ],
      ),
      SupervisorVerification(
        id: 'SUP-003',
        name: 'Sebastián Kwan',
        email: 'sebastian.kwan@rutasegura.com',
        phone: '+56 9 8120 4431',
        rut: '15.884.211-K',
        organization: 'Red Comunitaria Oriente',
        location: 'Temuco',
        submittedAt: DateTime(2026, 5, 30, 9, 20),
        documents: [
          VerificationDocument(
            id: 'DOC-003',
            title: 'Certificado de personalidad jurídica',
            fileName: 'certificado_personalidad_juridica_red_oriente.pdf',
            pageCount: 6,
            status: DocumentReviewStatus.pending,
          ),
        ],
      ),
    ];
  }

  List<RoutesQuantityPoint> getRoutesQuantityByPeriod(RoutesQuantityPeriod period) {
    return switch (period) {
      RoutesQuantityPeriod.lastWeek => const [
          RoutesQuantityPoint(label: 'Lun', quantity: 3),
          RoutesQuantityPoint(label: 'Mar', quantity: 5),
          RoutesQuantityPoint(label: 'Mie', quantity: 2),
          RoutesQuantityPoint(label: 'Jue', quantity: 7),
          RoutesQuantityPoint(label: 'Vie', quantity: 4),
          RoutesQuantityPoint(label: 'Sab', quantity: 6),
          RoutesQuantityPoint(label: 'Dom', quantity: 8),
        ],
      RoutesQuantityPeriod.lastMonth => const [
          RoutesQuantityPoint(label: 'Semana 1', quantity: 6),
          RoutesQuantityPoint(label: 'Semana 2', quantity: 8),
          RoutesQuantityPoint(label: 'Semana 3', quantity: 10),
          RoutesQuantityPoint(label: 'Semana 4', quantity: 7),
        ],
      RoutesQuantityPeriod.last6Months => const [
          RoutesQuantityPoint(label: 'Dic', quantity: 85),
          RoutesQuantityPoint(label: 'Ene', quantity: 92),
          RoutesQuantityPoint(label: 'Feb', quantity: 110),
          RoutesQuantityPoint(label: 'Mar', quantity: 135),
          RoutesQuantityPoint(label: 'Abr', quantity: 116),
          RoutesQuantityPoint(label: 'May', quantity: 128),
        ],
      RoutesQuantityPeriod.lastYear => const [
          RoutesQuantityPoint(label: 'Ene', quantity: 20),
          RoutesQuantityPoint(label: 'Feb', quantity: 25),
          RoutesQuantityPoint(label: 'Mar', quantity: 30),
          RoutesQuantityPoint(label: 'Abr', quantity: 28),
          RoutesQuantityPoint(label: 'May', quantity: 32),
          RoutesQuantityPoint(label: 'Jun', quantity: 35),
          RoutesQuantityPoint(label: 'Jul', quantity: 22),
          RoutesQuantityPoint(label: 'Ago', quantity: 27),
          RoutesQuantityPoint(label: 'Sep', quantity: 31),
          RoutesQuantityPoint(label: 'Oct', quantity: 29),
          RoutesQuantityPoint(label: 'Nov', quantity: 26),
          RoutesQuantityPoint(label: 'Dic', quantity: 34),
        ],
    };
  }

  List<SOSReportPoint> getSOSReportsByPeriod(SOSReportsPeriod period) {
    return switch (period) {
      SOSReportsPeriod.lastWeek => const [
          SOSReportPoint(label: 'Centro', quantity: 8),
          SOSReportPoint(label: 'Norte', quantity: 5),
          SOSReportPoint(label: 'Sur', quantity: 4),
          SOSReportPoint(label: 'Oriente', quantity: 3),
          SOSReportPoint(label: 'Poniente', quantity: 2),
        ],
      SOSReportsPeriod.lastMonth => const [
          SOSReportPoint(label: 'Centro', quantity: 24),
          SOSReportPoint(label: 'Norte', quantity: 18),
          SOSReportPoint(label: 'Poniente', quantity: 15),
          SOSReportPoint(label: 'Sur', quantity: 12),
          SOSReportPoint(label: 'Oriente', quantity: 9),
        ],
      SOSReportsPeriod.last6Months => const [
          SOSReportPoint(label: 'Centro', quantity: 68),
          SOSReportPoint(label: 'Norte', quantity: 51),
          SOSReportPoint(label: 'Sur', quantity: 43),
          SOSReportPoint(label: 'Poniente', quantity: 35),
          SOSReportPoint(label: 'Oriente', quantity: 29),
        ],
      SOSReportsPeriod.lastYear => const [
          SOSReportPoint(label: 'Centro', quantity: 126),
          SOSReportPoint(label: 'Norte', quantity: 98),
          SOSReportPoint(label: 'Sur', quantity: 84),
          SOSReportPoint(label: 'Poniente', quantity: 73),
          SOSReportPoint(label: 'Oriente', quantity: 61),
        ],
    };
  }
}

enum RoutesQuantityPeriod {
  lastWeek('Última semana'),
  lastMonth('Último mes'),
  last6Months('Últimos 6 meses'),
  lastYear('Último año');

  const RoutesQuantityPeriod(this.label);

  final String label;
}

class RoutesQuantityPoint {
  const RoutesQuantityPoint({
    required this.label,
    required this.quantity,
  });

  final String label;
  final int quantity;
}

enum SOSReportsPeriod {
  lastWeek('Última semana'),
  lastMonth('Último mes'),
  last6Months('Últimos 6 meses'),
  lastYear('Último año');

  const SOSReportsPeriod(this.label);

  final String label;
}

class SOSReportPoint {
  const SOSReportPoint({
    required this.label,
    required this.quantity,
  });

  final String label;
  final int quantity;
}

class AdminMetrics {
  const AdminMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.pendingUsers,
    required this.blockedUsers,
    required this.sosAlerts,
  });

  final int totalUsers;
  final int activeUsers;
  final int pendingUsers;
  final int blockedUsers;
  final int sosAlerts;
}
