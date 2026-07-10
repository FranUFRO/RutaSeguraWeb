import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
import '../services/dashboard_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  static const routeName = '/dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _DashboardViewData {
  const _DashboardViewData(this.users, this.activity);
  final List<AdminUser> users;
  final DashboardActivity activity;
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<_DashboardViewData> _future = _load();

  Future<_DashboardViewData> _load() async {
    final responses = await Future.wait([
      AppServices.users.getUsers(),
      AppServices.dashboard.getActivity(),
    ]);
    return _DashboardViewData(
      responses[0] as List<AdminUser>,
      responses[1] as DashboardActivity,
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Dashboard',
      subtitle: 'Vista general para gestionar usuarios de Ruta Segura.',
      selectedRoute: AdminDashboardScreen.routeName,
      child: FutureBuilder<_DashboardViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(error: snapshot.error.toString(), onRetry: _reload);
          }
          final data = snapshot.data!;
          final metrics = AdminMetrics.fromUsers(data.users);
          return SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 920
                        ? 4
                        : constraints.maxWidth >= 620
                            ? 2
                            : 1;
                    final cardHeight = columns == 1 ? 112.0 : 132.0;
                    final maxWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.sizeOf(context).width;
                    final spacing = AdminSpacing.md * (columns - 1);
                    final cardWidth = (maxWidth - spacing) / columns;
                    return Wrap(
                      spacing: AdminSpacing.md,
                      runSpacing: AdminSpacing.md,
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
                  }),
                  const SizedBox(height: AdminSpacing.lg),
                  Text(
                    'Actividad reciente',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AdminColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AdminSpacing.xs),
                  Text(
                    'Indicadores reales de alertas SOS y rutas completadas durante los ultimos 7 dias.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AdminColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AdminSpacing.md),
                  LayoutBuilder(builder: (context, constraints) {
                    final charts = [
                      _ActivityChart(
                        title: 'Alertas SOS por dia',
                        subtitle: '${data.activity.totalAlerts} alertas registradas',
                        points: data.activity.sosAlerts,
                        color: AdminColors.danger,
                        icon: Icons.sos_rounded,
                      ),
                      _ActivityChart(
                        title: 'Rutas completadas por sector',
                        subtitle: '${data.activity.totalCompletedRoutes} rutas completadas',
                        points: data.activity.routesBySector,
                        color: AdminColors.success,
                        icon: Icons.route_rounded,
                      ),
                    ];
                    if (constraints.maxWidth < 820) {
                      return Column(
                        children: [
                          charts[0],
                          const SizedBox(height: AdminSpacing.md),
                          charts[1],
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: charts[0]),
                        const SizedBox(width: AdminSpacing.md),
                        Expanded(child: charts[1]),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<DashboardChartPoint> points;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasData = points.any((point) => point.value > 0);
    final maximum = points.fold<int>(0, (current, point) => point.value > current ? point.value : current);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AdminColors.navy,
                          ),
                    ),
                    Text(subtitle, style: const TextStyle(color: AdminColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.lg),
          if (!hasData)
            const SizedBox(
              height: 190,
              child: Center(
                child: Text(
                  'Sin datos para el periodo.',
                  style: TextStyle(color: AdminColors.muted),
                ),
              ),
            )
          else
            SizedBox(
              height: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < points.length; index++) ...[
                    _ChartBar(
                      point: points[index],
                      maximum: maximum,
                      color: color,
                    ),
                    if (index != points.length - 1) const SizedBox(height: AdminSpacing.xs),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.point,
    required this.maximum,
    required this.color,
  });

  final DashboardChartPoint point;
  final int maximum;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            point.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AdminColors.muted),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 14,
              color: AdminColors.field,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: maximum == 0 ? 0 : point.value / maximum,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: AdminSpacing.xs),
        SizedBox(
          width: 28,
          child: Text(
            '${point.value}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AdminColors.danger),
            const SizedBox(height: AdminSpacing.sm),
            const Text('No se pudieron cargar los datos del dashboard.'),
            const SizedBox(height: AdminSpacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminColors.muted),
            ),
            const SizedBox(height: AdminSpacing.sm),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
}
