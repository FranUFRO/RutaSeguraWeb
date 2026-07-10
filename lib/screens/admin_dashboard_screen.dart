import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/routes_per_month_chart.dart';
import '../widgets/sos_reports_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<AdminUser>> _usersFuture = AppServices.users.getUsers();

  void _reload() {
    setState(() => _usersFuture = AppServices.users.getUsers());
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Inicio',
      subtitle: 'Vista general para gestionar usuarios de Ruta Segura.',
      selectedRoute: AdminDashboardScreen.routeName,
      child: FutureBuilder<List<AdminUser>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          final metrics = AdminMetrics.fromUsers(snapshot.data ?? const []);

          return ListView(
            children: [
              if (snapshot.connectionState == ConnectionState.waiting) ...[
                const LinearProgressIndicator(minHeight: 3),
                const SizedBox(height: AdminSpacing.md),
              ],
              if (snapshot.hasError) ...[
                _MetricsWarning(error: snapshot.error.toString(), onRetry: _reload),
                const SizedBox(height: AdminSpacing.md),
              ],
              _MetricsGrid(metrics: metrics),
              const SizedBox(height: AdminSpacing.md),
              const _DashboardCharts(),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardCharts extends StatelessWidget {
  const _DashboardCharts();

  static const double _chartHeight = 330;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: _chartHeight, child: RoutesQuantityChart()),
              SizedBox(height: AdminSpacing.md),
              SizedBox(height: _chartHeight, child: SOSReportsChart()),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(height: _chartHeight, child: RoutesQuantityChart())),
            SizedBox(width: AdminSpacing.md),
            Expanded(child: SizedBox(height: _chartHeight, child: SOSReportsChart())),
          ],
        );
      },
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final AdminMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final cardHeight = columns == 1 ? 88.0 : 112.0;
        final spacing = AdminSpacing.sm * (columns - 1);
        final cardWidth = (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: AdminSpacing.sm,
          runSpacing: AdminSpacing.sm,
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: MetricCard(
                label: 'Usuarios totales',
                value: '${metrics.totalUsers}',
                icon: Icons.groups_rounded,
                color: AdminColors.navy,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: MetricCard(
                label: 'Usuarios activos',
                value: '${metrics.activeUsers}',
                icon: Icons.check_circle_rounded,
                color: AdminColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: MetricCard(
                label: 'Pendientes',
                value: '${metrics.pendingUsers}',
                icon: Icons.schedule_rounded,
                color: AdminColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: MetricCard(
                label: 'Bloqueados',
                value: '${metrics.blockedUsers}',
                icon: Icons.block_rounded,
                color: AdminColors.danger,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricsWarning extends StatelessWidget {
  const _MetricsWarning({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AdminColors.warning),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Text(
              'No se pudieron cargar las métricas de usuarios. $error',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AdminColors.muted),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
