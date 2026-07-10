import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/dashboard_service.dart';

class SOSReportsChart extends StatefulWidget {
  const SOSReportsChart({
    super.key,
    this.initialPeriod = SOSReportsPeriod.last6Months,
  });

  final SOSReportsPeriod initialPeriod;

  static const Color _dangerColor = Color(0xFFDC2626);
  static const Color _titleColor = Color(0xFF111827);
  static const Color _textColor = Color(0xFF374151);
  static const Color _mutedColor = Color(0xFF6B7280);

  @override
  State<SOSReportsChart> createState() => _SOSReportsChartState();
}

class _SOSReportsChartState extends State<SOSReportsChart> {
  late SOSReportsPeriod _selectedPeriod = widget.initialPeriod;
  late Future<List<SOSReportPoint>> _future = _load();

  Future<List<SOSReportPoint>> _load() =>
      AppServices.dashboard.getSOSReportsByPeriod(_selectedPeriod);

  void _selectPeriod(SOSReportsPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _future = _load();
    });
  }

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
          _ChartHeader(
            selectedPeriod: _selectedPeriod,
            onSelected: _selectPeriod,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<SOSReportPoint>>(
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
                  return const _ChartMessage(message: 'Sin alertas SOS para el periodo.');
                }

                return _SOSBars(data: data);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader({
    required this.selectedPeriod,
    required this.onSelected,
  });

  final SOSReportsPeriod selectedPeriod;
  final ValueChanged<SOSReportsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alertas SOS registradas',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SOSReportsChart._titleColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Text(
                'Datos obtenidos desde el backend',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SOSReportsChart._mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        PopupMenuButton<SOSReportsPeriod>(
          tooltip: 'Filtrar periodo',
          onSelected: onSelected,
          itemBuilder: (context) => [
            for (final period in SOSReportsPeriod.values)
              PopupMenuItem(
                value: period,
                child: _PeriodMenuItem(label: period.label, selected: period == selectedPeriod),
              ),
          ],
          child: _PeriodButton(label: selectedPeriod.label),
        ),
      ],
    );
  }
}

class _SOSBars extends StatelessWidget {
  const _SOSBars({required this.data});

  final List<SOSReportPoint> data;

  int get _maxValue => data.fold<int>(0, (max, item) => item.quantity > max ? item.quantity : max);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < data.length; index++) ...[
          Expanded(
            child: _ReportBar(
              rank: index + 1,
              label: data[index].label,
              value: data[index].quantity,
              maxValue: _maxValue,
              color: _barColorFor(index),
            ),
          ),
          if (index != data.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }

  Color _barColorFor(int index) {
    const colors = [
      Color(0xFFDC2626),
      Color(0xFFF97316),
      Color(0xFFFFA726),
      Color(0xFFFFB74D),
      Color(0xFFFFCC80),
    ];
    return colors[index % colors.length];
  }
}

class _ReportBar extends StatelessWidget {
  const _ReportBar({
    required this.rank,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int rank;
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final factor = maxValue == 0 ? 0.0 : value / maxValue;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: SOSReportsChart._dangerColor,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SOSReportsChart._textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '$value',
                    style: const TextStyle(
                      color: SOSReportsChart._titleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    Container(height: 10, color: const Color(0xFFF3F4F6)),
                    FractionallySizedBox(
                      widthFactor: factor.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
              color: SOSReportsChart._textColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, color: SOSReportsChart._textColor, size: 17),
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
        if (selected) const Icon(Icons.check_rounded, size: 18, color: SOSReportsChart._dangerColor),
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
        style: const TextStyle(color: SOSReportsChart._mutedColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}
