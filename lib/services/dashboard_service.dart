import 'api_client.dart';
import 'auth_service.dart';

class DashboardChartPoint {
  const DashboardChartPoint(this.label, this.value);
  final String label;
  final int value;
}

class DashboardActivity {
  const DashboardActivity({
    required this.sosAlerts,
    required this.routesBySector,
    required this.totalAlerts,
    required this.totalCompletedRoutes,
  });

  final List<DashboardChartPoint> sosAlerts;
  final List<DashboardChartPoint> routesBySector;
  final int totalAlerts;
  final int totalCompletedRoutes;
}

class DashboardService {
  const DashboardService(this._api, this._auth);

  final ApiClient _api;
  final AuthService _auth;

  Future<DashboardActivity> getActivity({int days = 7}) async {
    final today = DateTime.now().toUtc();
    final firstDay = DateTime.utc(today.year, today.month, today.day)
        .subtract(Duration(days: days - 1));
    final from = _date(firstDay);
    final to = _date(today);
    final adminId = _auth.adminId;

    final responses = await Future.wait([
      _api.get('/$adminId/dashboard/sos-alerts?from=$from&to=$to&group_by=day'),
      _api.get('/$adminId/dashboard/routes-completed?from=$from&to=$to'),
    ]);

    final sosResponse = responses[0];
    final routesResponse = responses[1];
    final sosCounts = <String, int>{};
    for (final item in sosResponse['series'] as List? ?? const []) {
      final point = Map<String, dynamic>.from(item as Map);
      sosCounts[(point['label'] ?? '').toString()] = _integer(point['count']);
    }

    final alerts = List.generate(days, (index) {
      final date = firstDay.add(Duration(days: index));
      final key = _date(date);
      return DashboardChartPoint('${date.day}/${date.month}', sosCounts[key] ?? 0);
    });

    final sectors = (routesResponse['sectors'] as List? ?? const [])
        .map((item) {
          final sector = Map<String, dynamic>.from(item as Map);
          return DashboardChartPoint(
            _sectorLabel((sector['sector'] ?? 'Sin ubicacion').toString()),
            _integer(sector['count']),
          );
        })
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return DashboardActivity(
      sosAlerts: alerts,
      routesBySector: sectors.take(6).toList(),
      totalAlerts: _integer(sosResponse['total_results']),
      totalCompletedRoutes: _integer(routesResponse['total_results']),
    );
  }

  static int _integer(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _sectorLabel(String value) => value == 'sin_ubicacion' ? 'Sin ubicacion' : value;
}
