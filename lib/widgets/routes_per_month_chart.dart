import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/dashboard_service.dart';

class RoutesQuantityChart extends StatefulWidget {
  const RoutesQuantityChart({
    super.key,
    this.initialPeriod = RoutesQuantityPeriod.last6Months,
  });

  final RoutesQuantityPeriod initialPeriod;

  static const Color _barColor = Color(0xFF4F7CFF);
  static const Color _titleColor = Color(0xFF111827);
  static const Color _mutedColor = Color(0xFF6B7280);
  static const Color _gridColor = Color(0xFFE5E7EB);

  @override
  State<RoutesQuantityChart> createState() => _RoutesQuantityChartState();
}

class _RoutesQuantityChartState extends State<RoutesQuantityChart> {
  late RoutesQuantityPeriod _selectedPeriod = widget.initialPeriod;
  late Future<List<RoutesQuantityPoint>> _future = _load();

  Future<List<RoutesQuantityPoint>> _load() =>
      AppServices.dashboard.getRoutesQuantityByPeriod(_selectedPeriod);

  void _selectPeriod(RoutesQuantityPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ChartSurface(
      title: 'Cantidad de rutas realizadas',
      subtitle: 'Datos obtenidos desde el backend',
      menu: PopupMenuButton<RoutesQuantityPeriod>(
        tooltip: 'Filtrar periodo',
        onSelected: _selectPeriod,
        itemBuilder: (context) => [
          for (final period in RoutesQuantityPeriod.values)
            PopupMenuItem(
              value: period,
              child: _PeriodMenuItem(label: period.label, selected: period == _selectedPeriod),
            ),
        ],
        child: _PeriodButton(label: _selectedPeriod.label),
      ),
      child: FutureBuilder<List<RoutesQuantityPoint>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ChartMessage(message: snapshot.error.toString());
          }

          final data = snapshot.data ?? const [];
          if (data.isEmpty || data.every((point) => point.quantity == 0)) {
            return const _ChartMessage(message: 'Sin rutas completadas para el periodo.');
          }

          return _RoutesBarChart(data: data);
        },
      ),
    );
  }
}

class _RoutesBarChart extends StatelessWidget {
  const _RoutesBarChart({required this.data});

  final List<RoutesQuantityPoint> data;

  @override
  Widget build(BuildContext context) {
    final maxRoutes = data.fold<int>(0, (max, item) => math.max(max, item.quantity));
    final maxY = _niceMaxY(maxRoutes);
    final denseLabels = data.length > 8;
    final barWidth = data.length >= 12 ? 18.0 : data.length >= 7 ? 24.0 : 34.0;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        groupsSpace: denseLabels ? 10 : 18,
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.round().toString(),
                const TextStyle(
                  color: RoutesQuantityChart._titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
        ),
        barGroups: [
          for (var index = 0; index < data.length; index++)
            BarChartGroupData(
              x: index,
              showingTooltipIndicators: const [0],
              barRods: [
                BarChartRodData(
                  toY: data[index].quantity.toDouble(),
                  width: barWidth,
                  color: RoutesQuantityChart._barColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            ),
        ],
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: denseLabels ? 48 : 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 10,
                  child: Text(
                    data[index].label,
                    textAlign: TextAlign.center,
                    maxLines: denseLabels ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: RoutesQuantityChart._mutedColor,
                      fontSize: denseLabels ? 10 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: _yInterval(maxY),
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > maxY) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: RoutesQuantityChart._mutedColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _yInterval(maxY),
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: RoutesQuantityChart._gridColor,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  static double _niceMaxY(int maxValue) {
    if (maxValue <= 0) return 10;
    final step = maxValue <= 40 ? 10.0 : 25.0;
    return ((maxValue * 1.18) / step).ceil() * step;
  }

  static double _yInterval(double maxY) => math.max(5.0, (maxY / 4).ceilToDouble());
}

class _ChartSurface extends StatelessWidget {
  const _ChartSurface({
    required this.title,
    required this.subtitle,
    required this.menu,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget menu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: RoutesQuantityChart._titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RoutesQuantityChart._mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              menu,
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF374151), size: 17),
        ],
      ),
    );
  }
}

class _PeriodMenuItem extends StatelessWidget {
  const _PeriodMenuItem({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        if (selected) const Icon(Icons.check_rounded, size: 18, color: RoutesQuantityChart._barColor),
      ],
    );
  }
}

class _ChartMessage extends StatelessWidget {
  const _ChartMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: RoutesQuantityChart._mutedColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
