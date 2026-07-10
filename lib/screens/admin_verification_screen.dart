import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  static const String routeName = '/verificar';

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  bool _loading = true;
  String? _error;
  List<AdminUser> _pendingSupervisors = const [];
  int _selectedRequestIndex = 0;
  int _currentPage = 1;

  AdminUser? get _selectedRequest {
    if (_pendingSupervisors.isEmpty) return null;
    final index = _selectedRequestIndex.clamp(0, _pendingSupervisors.length - 1).toInt();
    return _pendingSupervisors[index];
  }

  int get _pendingDocumentCount => _pendingSupervisors.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await AppServices.users.getUsers();
      if (!mounted) return;
      final pending = users
          .where((user) => user.role == 'Supervisor' && user.status == AdminUserStatus.pending)
          .toList();
      setState(() {
        _pendingSupervisors = pending;
        _selectedRequestIndex = pending.isEmpty ? 0 : _selectedRequestIndex.clamp(0, pending.length - 1).toInt();
        _currentPage = 1;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectRequest(int index) {
    setState(() {
      _selectedRequestIndex = index;
      _currentPage = 1;
    });
  }

  void _showBackendLimitation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'El backend actual no entrega el ID del documento pendiente. No se puede validar de forma segura desde esta cola.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      subtitle: 'VERIFICACION DOCUMENTOS',
      title: 'Verificaciones Pendientes',
      selectedRoute: AdminVerificationScreen.routeName,
      actions: [
        _PendingDocumentsBadge(count: _pendingDocumentCount),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _VerificationError(error: _error!, onRetry: _load)
              : _pendingSupervisors.isEmpty
                  ? const _EmptyVerifications()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 980;
                        final selected = _selectedRequest!;

                        if (!wide) {
                          return ListView(
                            children: [
                              _BackendLimitationNotice(),
                              const SizedBox(height: AdminSpacing.md),
                              _SupervisorQueue(
                                requests: _pendingSupervisors,
                                selectedIndex: _selectedRequestIndex,
                                onSelected: _selectRequest,
                              ),
                              const SizedBox(height: AdminSpacing.md),
                              _VerificationDetail(
                                request: selected,
                                currentPage: _currentPage,
                                onPreviousPage: _currentPage == 1
                                    ? null
                                    : () => setState(() => _currentPage--),
                                onNextPage: _currentPage == 1
                                    ? null
                                    : () => setState(() => _currentPage++),
                                onBlockedAction: _showBackendLimitation,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 340,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _BackendLimitationNotice(),
                                    const SizedBox(height: AdminSpacing.md),
                                    _SupervisorQueue(
                                      requests: _pendingSupervisors,
                                      selectedIndex: _selectedRequestIndex,
                                      onSelected: _selectRequest,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AdminSpacing.md),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _VerificationDetail(
                                  request: selected,
                                  currentPage: _currentPage,
                                  onPreviousPage: null,
                                  onNextPage: null,
                                  onBlockedAction: _showBackendLimitation,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
    );
  }
}

class _BackendLimitationNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AdminColors.warning),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Text(
              'La cola se arma con supervisores pendientes desde la API. El backend actual permite consultar/validar un documento por ID, pero no lista los IDs de documentos pendientes; por eso las acciones quedan preparadas, no ejecutadas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdminColors.muted,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupervisorQueue extends StatelessWidget {
  const _SupervisorQueue({
    required this.requests,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AdminUser> requests;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AdminColors.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fact_check_rounded, color: AdminColors.selago),
              ),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Text(
                  'Supervisores pendientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AdminColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminSpacing.md),
          for (var index = 0; index < requests.length; index++) ...[
            _SupervisorRequestTile(
              request: requests[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
            if (index != requests.length - 1) const SizedBox(height: AdminSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SupervisorRequestTile extends StatelessWidget {
  const _SupervisorRequestTile({
    required this.request,
    required this.selected,
    required this.onTap,
  });

  final AdminUser request;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.selago : AdminColors.field,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AdminSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: selected ? AdminColors.navy : const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                child: Text(
                  request.initials,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _display(request.name),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AdminColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      _display(request.organization),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AdminColors.muted),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Certificado pendiente',
                      style: TextStyle(
                        color: AdminColors.warning,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AdminColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationDetail extends StatelessWidget {
  const _VerificationDetail({
    required this.request,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onBlockedAction,
  });

  final AdminUser request;
  final int currentPage;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final VoidCallback onBlockedAction;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewDocumentHeader(request: request),
          const SizedBox(height: AdminSpacing.md),
          _PdfReviewViewer(
            request: request,
            currentPage: currentPage,
            onPreviousPage: onPreviousPage,
            onNextPage: onNextPage,
          ),
          const SizedBox(height: AdminSpacing.md),
          _ReviewActions(onBlockedAction: onBlockedAction),
        ],
      ),
    );
  }
}

class _ReviewDocumentHeader extends StatelessWidget {
  const _ReviewDocumentHeader({required this.request});

  final AdminUser request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisar Documento',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AdminColors.navy,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: AdminSpacing.xs),
        Wrap(
          spacing: AdminSpacing.sm,
          runSpacing: AdminSpacing.xs,
          children: [
            _InlineInfo(label: 'Nombre', value: request.name),
            _InlineInfo(label: 'Organizacion', value: request.organization),
            _InlineInfo(label: 'RUT', value: request.rut),
          ],
        ),
        const SizedBox(height: AdminSpacing.xs),
        const Text(
          'Certificado de organizacion / supervisor',
          style: TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PdfReviewViewer extends StatelessWidget {
  const _PdfReviewViewer({
    required this.request,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final AdminUser request;
  final int currentPage;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.line),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AdminSpacing.md,
              vertical: AdminSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFE0E3E5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.zoom_in_rounded, color: AdminColors.navy, size: 18),
                const SizedBox(width: AdminSpacing.sm),
                const Icon(Icons.zoom_out_rounded, color: AdminColors.navy, size: 18),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Pagina $currentPage / 1',
                      style: const TextStyle(
                        color: AdminColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Pagina anterior',
                  onPressed: onPreviousPage,
                  color: AdminColors.navy,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  tooltip: 'Pagina siguiente',
                  onPressed: onNextPage,
                  color: AdminColors.navy,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AdminSpacing.md),
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Container(
                padding: const EdgeInsets.all(AdminSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: _PdfPagePreview(request: request),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPagePreview extends StatelessWidget {
  const _PdfPagePreview({required this.request});

  final AdminUser request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.route_rounded, color: AdminColors.navy),
            const SizedBox(width: AdminSpacing.sm),
            Expanded(
              child: Text(
                'Ruta Segura',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdminColors.navy,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AdminSpacing.lg),
        Text(
          'Certificado pendiente',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AdminColors.text,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AdminSpacing.sm),
        Text(
          _display(request.organization),
          style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AdminSpacing.lg),
        const _PdfLine(widthFactor: 1),
        const _PdfLine(widthFactor: 0.92),
        const _PdfLine(widthFactor: 0.78),
        const SizedBox(height: AdminSpacing.lg),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AdminColors.field,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdminColors.line),
          ),
          child: const Center(
            child: Icon(Icons.description_rounded, color: AdminColors.muted, size: 46),
          ),
        ),
        const Spacer(),
        const _PdfLine(widthFactor: 0.86),
        const _PdfLine(widthFactor: 0.66),
      ],
    );
  }
}

class _PdfLine extends StatelessWidget {
  const _PdfLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        margin: const EdgeInsets.only(bottom: AdminSpacing.sm),
        decoration: BoxDecoration(
          color: AdminColors.line,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({required this.onBlockedAction});

  final VoidCallback onBlockedAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final buttons = [
          _ReviewActionButton(
            label: 'Rechazar',
            icon: Icons.cancel_rounded,
            backgroundColor: const Color(0xFFFFDAD6),
            foregroundColor: AdminColors.danger,
            onPressed: onBlockedAction,
          ),
          _ReviewActionButton(
            label: 'Aprobar Documento',
            icon: Icons.check_circle_rounded,
            backgroundColor: AdminColors.navy,
            foregroundColor: Colors.white,
            onPressed: onBlockedAction,
          ),
        ];

        if (compact) {
          return Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: AdminSpacing.sm,
              runSpacing: AdminSpacing.sm,
              children: buttons,
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Wrap(spacing: AdminSpacing.sm, runSpacing: AdminSpacing.sm, children: buttons),
          ],
        );
      },
    );
  }
}

class _PendingDocumentsBadge extends StatelessWidget {
  const _PendingDocumentsBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md, vertical: AdminSpacing.sm),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pendientes',
            style: TextStyle(
              color: AdminColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdminColors.navy,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
        children: [
          TextSpan(
            text: _display(value),
            style: const TextStyle(color: AdminColors.text, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ReviewActionButton extends StatelessWidget {
  const _ReviewActionButton({
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
      width: 184,
      height: 44,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _VerificationError extends StatelessWidget {
  const _VerificationError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AdminCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 46, color: AdminColors.danger),
            const SizedBox(height: AdminSpacing.sm),
            const Text('No se pudieron cargar las verificaciones.'),
            const SizedBox(height: AdminSpacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminColors.muted),
            ),
            const SizedBox(height: AdminSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVerifications extends StatelessWidget {
  const _EmptyVerifications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AdminCard(
        child: Text(
          'No hay supervisores pendientes.',
          style: TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

String _display(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? 'No disponible' : text;
}
