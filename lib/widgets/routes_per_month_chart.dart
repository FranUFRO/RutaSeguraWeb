import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/admin_user_service.dart';

class RoutesQuantityChart extends StatefulWidget {
  const RoutesQuantityChart({
    super.key,
    this.service = const AdminUserService(),
    this.initialPeriod = RoutesQuantityPeriod.last6Months,
  });

  final AdminUserService service;
  final RoutesQuantityPeriod initialPeriod;

  static const Color _barColor = Color(0xFF4F7CFF);
  static const Color _titleColor = Color(0xFF111827);
  static const Color _textColor = Color(0xFF374151);
  static const Color _mutedColor = Color(0xFF6B7280);
  static const Color _gridColor = Color(0xFFE5E7EB);

  @override
  State<RoutesQuantityChart> createState() => _RoutesQuantityChartState();
}

class _RoutesQuantityChartState extends State<RoutesQuantityChart> {
  late RoutesQuantityPeriod _selectedPeriod = widget.initialPeriod;
  bool _menuOpen = false;

  List<RoutesQuantityPoint> get _data => widget.service.getRoutesQuantityByPeriod(_selectedPeriod);

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final maxRoutes = data.fold<int>(0, (max, item) => math.max(max, item.quantity));
    final maxY = _niceMaxY(maxRoutes);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final denseLabels = data.length > 8 || constraints.maxWidth < 720;
        final barWidth = _barWidth(data.length, constraints.maxWidth);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 14 : 18),
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChartHeader(
                    selectedPeriod: _selectedPeriod,
                    compact: compact,
                    menuOpen: _menuOpen,
                    onToggleMenu: () => setState(() => _menuOpen = !_menuOpen),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: compact ? 220 : 230,
                    child: BarChart(
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
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
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
                                if (index < 0 || index >= data.length) {
                                  return const SizedBox.shrink();
                                }

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
                                if (value == 0 || value > maxY) {
                                  return const SizedBox.shrink();
                                }
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
                    ),
                  ),
                ],
              ),
              if (_menuOpen)
                Positioned(
                  top: compact ? 82 : 38,
                  right: 0,
                  child: _InlinePeriodMenu(
                    selectedPeriod: _selectedPeriod,
                    onChanged: _selectPeriod,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _barWidth(int itemCount, double availableWidth) {
    if (itemCount >= 12 || availableWidth < 640) {
      return 18.0;
    }
    if (itemCount >= 7) {
      return 24.0;
    }
    return 34.0;
  }

  static double _niceMaxY(int maxValue) {
    if (maxValue <= 0) {
      return 10;
    }
    final step = maxValue <= 40 ? 10.0 : 25.0;
    final padded = maxValue * 1.18;
    return (padded / step).ceil() * step;
  }

  static double _yInterval(double maxY) {
    return math.max(5.0, (maxY / 4).ceilToDouble());
  }

  void _selectPeriod(RoutesQuantityPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _menuOpen = false;
    });
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader({
    required this.selectedPeriod,
    required this.compact,
    required this.menuOpen,
    required this.onToggleMenu,
  });

  final RoutesQuantityPeriod selectedPeriod;
  final bool compact;
  final bool menuOpen;
  final VoidCallback onToggleMenu;

  @override
  Widget build(BuildContext context) {
    final dropdown = _PeriodDropdown(
      selectedPeriod: selectedPeriod,
      menuOpen: menuOpen,
      onTap: onToggleMenu,
    );

    final title = Text(
      'Cantidad de rutas realizadas',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: RoutesQuantityChart._titleColor,
            fontWeight: FontWeight.w800,
          ),
    );

    final titleRow = compact
        ? Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              title,
              dropdown,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: title),
              const SizedBox(width: 10),
              dropdown,
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleRow,
        const SizedBox(height: 3),
        const Text(
          '2026',
          style: TextStyle(
            color: RoutesQuantityChart._mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selectedPeriod,
    required this.menuOpen,
    required this.onTap,
  });

  final RoutesQuantityPeriod selectedPeriod;
  final bool menuOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
              selectedPeriod.label,
              style: const TextStyle(
                color: RoutesQuantityChart._textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              menuOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: RoutesQuantityChart._textColor,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlinePeriodMenu extends StatelessWidget {
  const _InlinePeriodMenu({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final RoutesQuantityPeriod selectedPeriod;
  final ValueChanged<RoutesQuantityPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 210,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final period in RoutesQuantityPeriod.values)
              _InlinePeriodMenuItem(
                period: period,
                selected: period == selectedPeriod,
                onTap: () => onChanged(period),
              ),
          ],
        ),
      ),
    );
  }
}

class _InlinePeriodMenuItem extends StatelessWidget {
  const _InlinePeriodMenuItem({
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final RoutesQuantityPeriod period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: selected ? const Color(0xFFF3F6FF) : Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Text(
                period.label,
                style: TextStyle(
                  color: selected ? RoutesQuantityChart._barColor : RoutesQuantityChart._textColor,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_rounded, color: RoutesQuantityChart._barColor, size: 18),
          ],
        ),
      ),
    );
  }
}
