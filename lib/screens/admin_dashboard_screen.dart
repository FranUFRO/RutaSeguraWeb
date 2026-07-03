import 'package:flutter/material.dart';

import '../services/admin_user_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/routes_per_month_chart.dart';
import '../widgets/sos_reports_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final metrics = const AdminUserService().getMetrics();

    return AdminShell(
      title: 'Inicio',
      subtitle: 'Vista general para gestionar usuarios de Ruta Segura.',
      selectedRoute: routeName,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 920
                    ? 3
                    : constraints.maxWidth >= 620
                        ? 2
                        : 1;

                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: AdminSpacing.sm,
                  mainAxisSpacing: AdminSpacing.sm,
                  childAspectRatio: columns == 1
                      ? 4.4
                      : columns == 2
                          ? 3.8
                          : 4.2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    MetricCard(
                      label: 'Usuarios totales',
                      value: '${metrics.totalUsers}',
                      icon: Icons.groups_rounded,
                      color: AdminColors.navy,
                    ),
                    MetricCard(
                      label: 'Pendientes',
                      value: '${metrics.pendingUsers}',
                      icon: Icons.schedule_rounded,
                      color: AdminColors.warning,
                    ),
                    MetricCard(
                      label: 'Alerta SOS',
                      value: '${metrics.sosAlerts}',
                      icon: Icons.warning_amber_rounded,
                      color: AdminColors.danger,
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: AdminSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return const Column(
                    children: [
                      RoutesQuantityChart(),
                      SizedBox(height: AdminSpacing.md),
                      SOSReportsChart(),
                    ],
                  );
                }

                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: RoutesQuantityChart()),
                    SizedBox(width: AdminSpacing.md),
                    Expanded(child: SOSReportsChart()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
