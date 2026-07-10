// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../models/supervisor_verification.dart';
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
  bool _validating = false;
  bool _showingReviewDialog = false;
  String? _error;
  List<SupervisorVerification> _verifications = const [];
  int _selectedIndex = 0;
  Future<SupervisorDocumentFile>? _documentFuture;

  SupervisorVerification? get _selectedRequest {
    if (_verifications.isEmpty) return null;
    final index = _selectedIndex.clamp(0, _verifications.length - 1).toInt();
    return _verifications[index];
  }

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
      final verifications = await AppServices.documents.getPendingVerifications();
      if (!mounted) return;
      final nextIndex = verifications.isEmpty ? 0 : _selectedIndex.clamp(0, verifications.length - 1).toInt();
      setState(() {
        _verifications = verifications;
        _selectedIndex = nextIndex;
        _documentFuture = _documentFutureFor(verifications.isEmpty ? null : verifications[nextIndex]);
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<SupervisorDocumentFile>? _documentFutureFor(SupervisorVerification? verification) {
    final documentId = verification?.primaryDocument?.id;
    if (documentId == null || documentId.isEmpty) return null;
    return AppServices.documents.getDocument(documentId);
  }

  void _selectRequest(int index) {
    final selected = _verifications[index];
    setState(() {
      _selectedIndex = index;
      _documentFuture = _documentFutureFor(selected);
    });
  }

  Future<void> _validateSelected(DocumentReviewStatus status) async {
    final selected = _selectedRequest;
    final documentId = selected?.primaryDocument?.id;
    if (selected == null || documentId == null || documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay documento seleccionado para validar.')),
      );
      return;
    }

    setState(() => _showingReviewDialog = true);
    final confirmed = await _confirmValidation(status, selected);
    if (mounted) setState(() => _showingReviewDialog = false);
    if (confirmed != true) return;

    final notes = status == DocumentReviewStatus.approved ? 'Documento aprobado.' : 'Documento rechazado.';

    setState(() => _validating = true);
    try {
      await AppServices.documents.validateDocument(
        documentId: documentId,
        status: status,
        notes: notes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == DocumentReviewStatus.approved ? 'Documento aprobado.' : 'Documento rechazado.'),
        ),
      );
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible validar el documento: $error'),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<bool?> _confirmValidation(DocumentReviewStatus status, SupervisorVerification request) async {
    final approving = status == DocumentReviewStatus.approved;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(approving ? 'Aprobar documento' : 'Rechazar documento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                approving
                    ? '¿Estás seguro de que deseas aprobar este documento?'
                    : '¿Estás seguro de que deseas rechazar este documento?',
              ),
              const SizedBox(height: AdminSpacing.md),
              Container(
                padding: const EdgeInsets.all(AdminSpacing.md),
                decoration: BoxDecoration(
                  color: AdminColors.field,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AdminColors.navy,
                      foregroundColor: AdminColors.selago,
                      child: Text(request.initials),
                    ),
                    const SizedBox(width: AdminSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _display(request.name),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            _display(request.email),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AdminColors.muted),
                          ),
                          Text(
                            request.primaryDocument?.fileName ?? 'Documento supervisor',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AdminColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, false),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.selago,
                  foregroundColor: AdminColors.navy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            SizedBox(
              height: 44,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: Icon(approving ? Icons.check_circle_rounded : Icons.cancel_rounded),
                label: Text(approving ? 'Aprobar' : 'Rechazar'),
                style: FilledButton.styleFrom(
                  backgroundColor: approving ? AdminColors.success : AdminColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      subtitle: 'Verificación de documentos',
      title: 'Verificaciones pendientes',
      selectedRoute: AdminVerificationScreen.routeName,
      actions: [
        _PendingDocumentsBadge(count: _verifications.length),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _VerificationError(error: _error!, onRetry: _load)
              : _verifications.isEmpty
                  ? const _EmptyVerifications()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 980;
                        final selected = _selectedRequest!;
                        final detail = _VerificationDetail(
                          request: selected,
                          documentFuture: _documentFuture,
                          validating: _validating,
                          hidePdf: _showingReviewDialog,
                          onApprove: () => _validateSelected(DocumentReviewStatus.approved),
                          onReject: () => _validateSelected(DocumentReviewStatus.rejected),
                        );

                        if (!wide) {
                          return ListView(
                            children: [
                              _SupervisorQueue(
                                requests: _verifications,
                                selectedIndex: _selectedIndex,
                                onSelected: _selectRequest,
                              ),
                              const SizedBox(height: AdminSpacing.md),
                              detail,
                            ],
                          );
                        }

                        return ListView(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 292,
                                  child: _SupervisorQueue(
                                    requests: _verifications,
                                    selectedIndex: _selectedIndex,
                                    onSelected: _selectRequest,
                                  ),
                                ),
                                const SizedBox(width: AdminSpacing.md),
                                Expanded(child: detail),
                              ],
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

  final SupervisorVerification request;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final document = request.primaryDocument;
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
                    Text(
                      document?.fileName ?? 'Certificado pendiente',
                      overflow: TextOverflow.ellipsis,
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
    required this.documentFuture,
    required this.validating,
    required this.hidePdf,
    required this.onApprove,
    required this.onReject,
  });

  final SupervisorVerification request;
  final Future<SupervisorDocumentFile>? documentFuture;
  final bool validating;
  final bool hidePdf;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminCard(
          padding: const EdgeInsets.all(AdminSpacing.md),
          child: _ReviewDocumentHeader(
            request: request,
            actions: _ReviewActions(
              validating: validating,
              onApprove: onApprove,
              onReject: onReject,
            ),
          ),
        ),
        const SizedBox(height: AdminSpacing.md),
        _PdfReviewViewer(documentFuture: documentFuture, hidePdf: hidePdf),
      ],
    );
  }
}

class _ReviewDocumentHeader extends StatelessWidget {
  const _ReviewDocumentHeader({required this.request, required this.actions});

  final SupervisorVerification request;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final document = request.primaryDocument;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revisar documento',
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
            _InlineInfo(label: 'Organización', value: request.organization),
            _InlineInfo(label: 'RUT', value: request.rut),
          ],
        ),
        const SizedBox(height: AdminSpacing.xs),
        Text(
          document?.fileName ?? 'Certificado de organización / supervisor',
          style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              info,
              const SizedBox(height: AdminSpacing.md),
              actions,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: info),
            const SizedBox(width: AdminSpacing.md),
            actions,
          ],
        );
      },
    );
  }
}

class _PdfReviewViewer extends StatelessWidget {
  const _PdfReviewViewer({required this.documentFuture, required this.hidePdf});

  final Future<SupervisorDocumentFile>? documentFuture;
  final bool hidePdf;

  @override
  Widget build(BuildContext context) {
    if (documentFuture == null) {
      return const _PdfStateMessage(
        icon: Icons.description_outlined,
        message: 'Esta verificación no tiene documento asociado.',
      );
    }

    return FutureBuilder<SupervisorDocumentFile>(
      future: documentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 520,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _PdfStateMessage(
            icon: Icons.cloud_off_rounded,
            message: snapshot.error.toString(),
          );
        }

        final document = snapshot.data!;
        if (document.contentBase64.trim().isEmpty) {
          return const _PdfStateMessage(
            icon: Icons.description_outlined,
            message: 'El backend no entregó contenido para este PDF.',
          );
        }

        if (hidePdf) {
          return const _PdfStateMessage(
            icon: Icons.picture_as_pdf_rounded,
            message: 'PDF pausado mientras confirmas la acción.',
          );
        }

        return Container(
          padding: const EdgeInsets.all(AdminSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AdminColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PdfToolbar(document: document),
              const SizedBox(height: AdminSpacing.md),
              SizedBox(
                height: 760,
                child: _PdfIframe(document: document),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PdfToolbar extends StatelessWidget {
  const _PdfToolbar({required this.document});

  final SupervisorDocumentFile document;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md, vertical: AdminSpacing.sm),
      decoration: BoxDecoration(
        color: AdminColors.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded, color: AdminColors.danger),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Text(
              document.fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AdminColors.text, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Abrir PDF en pestaña nueva',
            onPressed: () => _openPdf(document),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }
}

class _PdfIframe extends StatefulWidget {
  const _PdfIframe({required this.document});

  final SupervisorDocumentFile document;

  @override
  State<_PdfIframe> createState() => _PdfIframeState();
}

class _PdfIframeState extends State<_PdfIframe> {
  late String _viewType;
  String? _objectUrl;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant _PdfIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.contentBase64 != widget.document.contentBase64) {
      _disposeObjectUrl();
      _registerView();
    }
  }

  @override
  void dispose() {
    _disposeObjectUrl();
    super.dispose();
  }

  void _registerView() {
    final bytes = _pdfBytes(widget.document.contentBase64);
    final blob = html.Blob([bytes], 'application/pdf');
    _objectUrl = html.Url.createObjectUrlFromBlob(blob);
    _viewType = 'supervisor-pdf-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return html.IFrameElement()
        ..src = _objectUrl!
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }

  void _disposeObjectUrl() {
    final url = _objectUrl;
    if (url != null) html.Url.revokeObjectUrl(url);
    _objectUrl = null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.line),
          borderRadius: BorderRadius.circular(14),
        ),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}

class _PdfStateMessage extends StatelessWidget {
  const _PdfStateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: AdminColors.field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AdminColors.line),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AdminSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AdminColors.muted, size: 48),
              const SizedBox(height: AdminSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.validating,
    required this.onApprove,
    required this.onReject,
  });

  final bool validating;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: AdminSpacing.sm,
        runSpacing: AdminSpacing.sm,
        children: [
          _ReviewActionButton(
            label: 'Rechazar',
            icon: Icons.cancel_rounded,
            backgroundColor: const Color(0xFFFFDAD6),
            foregroundColor: AdminColors.danger,
            onPressed: validating ? null : onReject,
          ),
          _ReviewActionButton(
            label: 'Aprobar documento',
            icon: Icons.check_circle_rounded,
            backgroundColor: AdminColors.navy,
            foregroundColor: Colors.white,
            loading: validating,
            onPressed: validating ? null : onApprove,
          ),
        ],
      ),
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
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 44,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.55),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.85),
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

void _openPdf(SupervisorDocumentFile document) {
  final bytes = _pdfBytes(document.contentBase64);
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  Future<void>.delayed(const Duration(seconds: 5), () => html.Url.revokeObjectUrl(url));
}

List<int> _pdfBytes(String value) {
  final clean = value.contains(',') ? value.split(',').last : value;
  return base64Decode(clean.trim());
}

String _display(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? 'No disponible' : text;
}
