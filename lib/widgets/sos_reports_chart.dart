import 'package:flutter/material.dart';

import '../services/admin_user_service.dart';

class SOSReportsChart extends StatefulWidget {
  const SOSReportsChart({
    super.key,
    this.service = const AdminUserService(),
    this.initialPeriod = SOSReportsPeriod.last6Months,
  });

  final AdminUserService service;
  final SOSReportsPeriod initialPeriod;

  static const Color _barColor = Color(0xFFFF6B35);
  static const Color _dangerColor = Color(0xFFDC2626);
  static const Color _titleColor = Color(0xFF111827);
  static const Color _textColor = Color(0xFF374151);
  static const Color _mutedColor = Color(0xFF6B7280);

  @override
  State<SOSReportsChart> createState() => _SOSReportsChartState();
}

class _SOSReportsChartState extends State<SOSReportsChart> {
  late SOSReportsPeriod _selectedPeriod = widget.initialPeriod;
  bool _menuOpen = false;

  List<SOSReportPoint> get _data => widget.service.getSOSReportsByPeriod(_selectedPeriod);

  int get _maxValue => _data.fold<int>(0, (max, item) => item.quantity > max ? item.quantity : max);

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

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
                    child: Column(
                      children: [
                        for (var index = 0; index < data.length; index++) ...[
                          Expanded(
                            child: _SectorRankingBar(
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

  void _selectPeriod(SOSReportsPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _menuOpen = false;
    });
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

class _ChartHeader extends StatelessWidget {
  const _ChartHeader({
    required this.selectedPeriod,
    required this.compact,
    required this.menuOpen,
    required this.onToggleMenu,
  });

  final SOSReportsPeriod selectedPeriod;
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
      'Alertas SOS por sector',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: SOSReportsChart._titleColor,
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
          'Top de sectores con mas reportes registrados',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: SOSReportsChart._mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectorRankingBar extends StatelessWidget {
  const _SectorRankingBar({
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
                    Container(
                      height: 10,
                      color: const Color(0xFFF3F4F6),
                    ),
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

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selectedPeriod,
    required this.menuOpen,
    required this.onTap,
  });

  final SOSReportsPeriod selectedPeriod;
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
                color: SOSReportsChart._textColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              menuOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: SOSReportsChart._textColor,
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

  final SOSReportsPeriod selectedPeriod;
  final ValueChanged<SOSReportsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          for (final period in SOSReportsPeriod.values)
            _InlinePeriodMenuItem(
              period: period,
              selected: period == selectedPeriod,
              onTap: () => onChanged(period),
            ),
        ],
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

  final SOSReportsPeriod period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: selected ? const Color(0xFFFFF1E8) : Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Text(
                period.label,
                style: TextStyle(
                  color: selected ? SOSReportsChart._dangerColor : SOSReportsChart._textColor,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_rounded, color: SOSReportsChart._dangerColor, size: 18),
          ],
        ),
      ),
    );
  }
}
