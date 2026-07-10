import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key, required this.userId});

  static const String routeName = '/usuarios/detalles';

  final String userId;

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<AdminUser> _future = AppServices.users.getUserById(widget.userId);

  void _reload() {
    setState(() => _future = AppServices.users.getUserById(widget.userId));
  }

  Future<void> _openEdit(AdminUser user) async {
    await Navigator.pushNamed(context, '/usuarios/editar', arguments: user.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Detalles de usuario',
      subtitle: 'Informacion del perfil y datos personales.',
      selectedRoute: '/usuarios',
      child: FutureBuilder<AdminUser>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _DetailsError(
              error: snapshot.error.toString(),
              onRetry: _reload,
            );
          }

          final user = snapshot.data!;
          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: PrimaryAdminButton(
                  label: 'Editar',
                  icon: Icons.edit_rounded,
                  onPressed: () => _openEdit(user),
                ),
              ),
              const SizedBox(height: AdminSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 860;
                    final profile = _ProfileBlock(user: user);
                    final data = _UserDataBlock(user: user);

                    if (compact) {
                      return ListView(
                        children: [
                          profile,
                          const SizedBox(height: AdminSpacing.md),
                          data,
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: profile),
                          const SizedBox(width: AdminSpacing.md),
                          Expanded(child: data),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AdminColors.navy,
            foregroundColor: AdminColors.selago,
            child: Text(
              user.initials,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AdminSpacing.sm),
          Text(
            _display(user.name),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdminColors.navy,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AdminSpacing.xs),
          StatusChip(status: user.status),
          const SizedBox(height: AdminSpacing.sm),
          _ProfileFact(icon: Icons.badge_rounded, label: 'Rol', value: user.role),
          if (_isSupervisor(user))
            _ProfileFact(
              icon: Icons.business_rounded,
              label: 'Organizacion',
              value: user.organization,
            ),
          _ProfileFact(
            icon: Icons.access_time_rounded,
            label: 'Ultima vez activo',
            value: _formatDate(user.lastAccess),
          ),
          _ProfileFact(
            icon: Icons.event_available_rounded,
            label: 'Fecha de creacion',
            value: _formatDate(user.createdAt),
          ),
        ],
      ),
    );
  }
}

class _UserDataBlock extends StatelessWidget {
  const _UserDataBlock({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de usuario',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AdminColors.navy,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AdminSpacing.sm),
          _DetailRow(icon: Icons.person_rounded, label: 'Nombre completo', value: user.name),
          _DetailRow(icon: Icons.mail_rounded, label: 'Correo electronico', value: user.email),
          _DetailRow(icon: Icons.credit_card_rounded, label: 'RUT', value: user.rut),
          _DetailRow(icon: Icons.phone_rounded, label: 'Numero', value: user.phone),
          _DetailRow(icon: Icons.business_center_rounded, label: 'Rol', value: user.role),
          if (_isSupervisor(user))
            _DetailRow(icon: Icons.business_rounded, label: 'Organizacion', value: user.organization),
          _DetailRow(
            icon: Icons.home_rounded,
            label: 'Direccion principal',
            value: user.primaryAddress,
          ),
        ],
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  const _ProfileFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.sm, vertical: AdminSpacing.xs),
      decoration: BoxDecoration(
        color: AdminColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AdminColors.navy, size: 18),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _display(value),
                  style: const TextStyle(
                    color: AdminColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AdminColors.selago,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AdminColors.navy, size: 20),
          ),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AdminColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _display(value),
                  style: const TextStyle(
                    color: AdminColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({
    required this.error,
    required this.onRetry,
  });

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
            const Text('No se pudieron cargar los detalles del usuario.'),
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

String _display(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? 'No disponible' : text;
}

bool _isSupervisor(AdminUser user) {
  return user.role.trim().toLowerCase() == 'supervisor';
}

String _formatDate(DateTime? date) {
  if (date == null) return 'No disponible';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
