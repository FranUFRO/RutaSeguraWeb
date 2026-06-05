import 'package:flutter/material.dart';

import '../models/supervisor_verification.dart';
import '../services/admin_user_service.dart';
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
  late final List<SupervisorVerification> _requests =
      const AdminUserService().getPendingSupervisorVerifications();
  int _selectedRequestIndex = 0;
  int _currentPage = 1;

  SupervisorVerification get _selectedRequest => _requests[_selectedRequestIndex];

  VerificationDocument get _selectedDocument => _selectedRequest.documents.first;

  int get _pendingDocumentCount => _requests.fold<int>(
        0,
        (total, request) => total + request.documents.where((document) => document.status == DocumentReviewStatus.pending).length,
      );

  void _selectRequest(int index) {
    setState(() {
      _selectedRequestIndex = index;
      _currentPage = 1;
    });
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;

          if (!wide) {
            return ListView(
              children: [
                _SupervisorQueue(
                  requests: _requests,
                  selectedIndex: _selectedRequestIndex,
                  onSelected: _selectRequest,
                ),
                const SizedBox(height: AdminSpacing.md),
                _VerificationDetail(
                  request: _selectedRequest,
                  document: _selectedDocument,
                  currentPage: _currentPage,
                  onPreviousPage: _currentPage == 1
                      ? null
                      : () => setState(() => _currentPage--),
                  onNextPage: _currentPage == _selectedDocument.pageCount
                      ? null
                      : () => setState(() => _currentPage++),
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
                  child: _SupervisorQueue(
                    requests: _requests,
                    selectedIndex: _selectedRequestIndex,
                    onSelected: _selectRequest,
                  ),
                ),
              ),
              const SizedBox(width: AdminSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: _VerificationDetail(
                    request: _selectedRequest,
                    document: _selectedDocument,
                    currentPage: _currentPage,
                    onPreviousPage: _currentPage == 1
                        ? null
                        : () => setState(() => _currentPage--),
                    onNextPage: _currentPage == _selectedDocument.pageCount
                        ? null
                        : () => setState(() => _currentPage++),
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

class _SupervisorQueue extends StatelessWidget {
  const _SupervisorQueue({
    required this.requests,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SupervisorVerification> requests;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supervisores pendientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AdminColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
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

  final SupervisorVerification request;
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
                      request.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AdminColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      request.organization,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AdminColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Certificado pendiente',
                      style: const TextStyle(
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
    required this.document,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final SupervisorVerification request;
  final VerificationDocument document;
  final int currentPage;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewDocumentHeader(request: request, document: document),
          const SizedBox(height: AdminSpacing.md),
          _PdfReviewViewer(
            document: document,
            currentPage: currentPage,
            onPreviousPage: onPreviousPage,
            onNextPage: onNextPage,
          ),
          const SizedBox(height: AdminSpacing.md),
          const _ReviewActions(),
        ],
      ),
    );
  }
}

class _ReviewDocumentHeader extends StatelessWidget {
  const _ReviewDocumentHeader({
    required this.request,
    required this.document,
  });

  final SupervisorVerification request;
  final VerificationDocument document;

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
        Text(
          document.title,
          style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PdfReviewViewer extends StatelessWidget {
  const _PdfReviewViewer({
    required this.document,
    required this.currentPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final VerificationDocument document;
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
                      'Pagina $currentPage / ${document.pageCount}',
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
                child: _PdfPagePreview(
                  document: document,
                  currentPage: currentPage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPagePreview extends StatelessWidget {
  const _PdfPagePreview({
    required this.document,
    required this.currentPage,
  });

  final VerificationDocument document;
  final int currentPage;

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
          document.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AdminColors.text,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AdminSpacing.sm),
        Text(
          'Pagina $currentPage de ${document.pageCount}',
          style: const TextStyle(color: AdminColors.muted),
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
  const _ReviewActions();

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
            onPressed: () {},
          ),
          _ReviewActionButton(
            label: 'Aprobar Documento',
            icon: Icons.check_circle_rounded,
            backgroundColor: AdminColors.navy,
            foregroundColor: Colors.white,
            onPressed: () {},
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
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
        children: [
          TextSpan(
            text: value,
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
