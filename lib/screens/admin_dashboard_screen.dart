import 'package:flutter/material.dart';

import '../services/admin_user_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final metrics = const AdminUserService().getMetrics();

    return AdminShell(
      title: 'Dashboard',
      subtitle: 'Vista general para gestionar usuarios de Ruta Segura.',
      selectedRoute: routeName,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 920
                    ? 4
                    : constraints.maxWidth >= 620
                        ? 2
                        : 1;

                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: AdminSpacing.md,
                  mainAxisSpacing: AdminSpacing.md,
                  childAspectRatio: columns == 1 ? 3.5 : 2.2,
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
                      label: 'Usuarios activos',
                      value: '${metrics.activeUsers}',
                      icon: Icons.check_circle_rounded,
                      color: AdminColors.success,
                    ),
                    MetricCard(
                      label: 'Pendientes',
                      value: '${metrics.pendingUsers}',
                      icon: Icons.schedule_rounded,
                      color: AdminColors.warning,
                    ),
                    MetricCard(
                      label: 'Bloqueados',
                      value: '${metrics.blockedUsers}',
                      icon: Icons.block_rounded,
                      color: AdminColors.danger,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AdminSpacing.lg),
            AdminCard(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final panel = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operacion administrativa',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AdminColors.navy,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AdminSpacing.sm),
                      Text(
                        'Revisa usuarios, valida solicitudes y manten la informacion actualizada desde un panel limpio y responsive.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AdminColors.muted,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: AdminSpacing.lg),
                      Wrap(
                        spacing: AdminSpacing.sm,
                        runSpacing: AdminSpacing.sm,
                        children: [
                          _DashboardActionButton(
                            label: 'Ver usuarios',
                            icon: Icons.people_alt_rounded,
                            backgroundColor: AdminColors.navy,
                            foregroundColor: AdminColors.selago,
                            onPressed: () => Navigator.pushNamed(context, '/usuarios'),
                          ),
                          _DashboardActionButton(
                            label: 'Verificar usuarios',
                            icon: Icons.verified_user_rounded,
                            backgroundColor: AdminColors.success,
                            foregroundColor: Colors.white,
                            onPressed: () => Navigator.pushNamed(context, '/verificar'),
                          ),
                        ],
                      ),
                    ],
                  );
                  final icon = Container(
                    width: compact ? double.infinity : 220,
                    height: compact ? 140 : 220,
                    decoration: BoxDecoration(
                      color: AdminColors.selago,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 86,
                      color: AdminColors.navy,
                    ),
                  );

                  if (compact) {
                    return Column(
                      children: [
                        icon,
                        const SizedBox(height: AdminSpacing.lg),
                        panel,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: panel),
                      const SizedBox(width: AdminSpacing.lg),
                      icon,
                    ],
                  );
                },
              ),
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
