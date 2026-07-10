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

  Future<List<RoutesQuantityPoint>> getRoutesQuantityByPeriod(RoutesQuantityPeriod period) async {
    final range = _PeriodRange.fromRoutesPeriod(period);
    final response = await _api.get('/${_auth.adminId}/dashboard/routes-completed?from=${range.from}&to=${range.to}');
    final buckets = _emptyBuckets(range);

    for (final item in response['routes'] as List? ?? const []) {
      final route = Map<String, dynamic>.from(item as Map);
      final date = DateTime.tryParse((route['date'] ?? route['ending_datetime'] ?? '').toString());
      if (date == null) continue;
      final key = _bucketKey(date.toUtc(), range);
      if (buckets.containsKey(key)) {
        buckets[key] = buckets[key]! + 1;
      }
    }

    return buckets.entries
        .map((entry) => RoutesQuantityPoint(label: entry.key, quantity: entry.value))
        .toList();
  }

  Future<List<SOSReportPoint>> getSOSReportsByPeriod(SOSReportsPeriod period) async {
    final range = _PeriodRange.fromSosPeriod(period);
    final response = await _api.get(
      '/${_auth.adminId}/dashboard/sos-alerts?from=${range.from}&to=${range.to}&group_by=${range.groupBy}',
    );
    final buckets = _emptyBuckets(range);

    for (final item in response['series'] as List? ?? const []) {
      final point = Map<String, dynamic>.from(item as Map);
      final rawLabel = (point['label'] ?? '').toString();
      final label = _normalizeBackendLabel(rawLabel, range);
      if (buckets.containsKey(label)) {
        buckets[label] = _integer(point['count']);
      }
    }

    return buckets.entries
        .map((entry) => SOSReportPoint(label: entry.key, quantity: entry.value))
        .toList();
  }

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
            _sectorLabel((sector['sector'] ?? 'Sin ubicación').toString()),
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

  static String _sectorLabel(String value) => value == 'sin_ubicacion' ? 'Sin ubicación' : value;

  static Map<String, int> _emptyBuckets(_PeriodRange range) {
    final result = <String, int>{};
    var cursor = range.start;
    while (!cursor.isAfter(range.end)) {
      result[_bucketKey(cursor, range)] = 0;
      cursor = range.groupBy == 'month'
          ? DateTime.utc(cursor.year, cursor.month + 1, 1)
          : cursor.add(const Duration(days: 1));
    }
    return result;
  }

  static String _bucketKey(DateTime date, _PeriodRange range) {
    if (range.groupBy == 'month') {
      return _monthLabel(date.month);
    }
    if (range.labelWeekdays) {
      return _weekdayLabel(date.weekday);
    }
    return '${date.day}/${date.month}';
  }

  static String _normalizeBackendLabel(String value, _PeriodRange range) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return _bucketKey(parsed.toUtc(), range);

    final yearMonth = RegExp(r'^\d{4}-(\d{2})$').firstMatch(value);
    if (range.groupBy == 'month' && yearMonth != null) {
      return _monthLabel(int.tryParse(yearMonth.group(1) ?? '') ?? 1);
    }

    final month = int.tryParse(value);
    if (range.groupBy == 'month' && month != null) return _monthLabel(month);

    return switch (value.trim().toLowerCase()) {
      'lunes' => 'Lun',
      'martes' => 'Mar',
      'miercoles' || 'miércoles' => 'Mie',
      'jueves' => 'Jue',
      'viernes' => 'Vie',
      'sabado' || 'sábado' => 'Sab',
      'domingo' => 'Dom',
      _ => value,
    };
  }

  static String _monthLabel(int month) => const [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ][month.clamp(1, 12).toInt() - 1];

  static String _weekdayLabel(int weekday) => const [
        'Lun',
        'Mar',
        'Mie',
        'Jue',
        'Vie',
        'Sab',
        'Dom',
      ][weekday.clamp(1, 7).toInt() - 1];
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

class _PeriodRange {
  const _PeriodRange({
    required this.start,
    required this.end,
    required this.groupBy,
    this.labelWeekdays = false,
  });

  final DateTime start;
  final DateTime end;
  final String groupBy;
  final bool labelWeekdays;

  String get from => DashboardService._date(start);
  String get to => DashboardService._date(end);

  static _PeriodRange fromRoutesPeriod(RoutesQuantityPeriod period) {
    final today = _today();
    return switch (period) {
      RoutesQuantityPeriod.lastWeek => _PeriodRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
          groupBy: 'day',
          labelWeekdays: true,
        ),
      RoutesQuantityPeriod.lastMonth => _PeriodRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
          groupBy: 'day',
        ),
      RoutesQuantityPeriod.last6Months => _PeriodRange(
          start: DateTime.utc(today.year, today.month - 5, 1),
          end: today,
          groupBy: 'month',
        ),
      RoutesQuantityPeriod.lastYear => _PeriodRange(
          start: DateTime.utc(today.year, today.month - 11, 1),
          end: today,
          groupBy: 'month',
        ),
    };
  }

  static _PeriodRange fromSosPeriod(SOSReportsPeriod period) {
    final today = _today();
    return switch (period) {
      SOSReportsPeriod.lastWeek => _PeriodRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
          groupBy: 'day',
          labelWeekdays: true,
        ),
      SOSReportsPeriod.lastMonth => _PeriodRange(
          start: today.subtract(const Duration(days: 29)),
          end: today,
          groupBy: 'day',
        ),
      SOSReportsPeriod.last6Months => _PeriodRange(
          start: DateTime.utc(today.year, today.month - 5, 1),
          end: today,
          groupBy: 'month',
        ),
      SOSReportsPeriod.lastYear => _PeriodRange(
          start: DateTime.utc(today.year, today.month - 11, 1),
          end: today,
          groupBy: 'month',
        ),
    };
  }

  static DateTime _today() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }
}
