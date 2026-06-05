import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key, required this.userId});

  static const String routeName = '/usuarios/detalles';

  final String userId;

  @override
  Widget build(BuildContext context) {
    final user = const AdminUserService().getUserById(userId);

    return AdminShell(
      title: 'Detalles de usuario',
      subtitle: 'Informacion del perfil y datos personales.',
      selectedRoute: '/usuarios',
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryAdminButton(
              label: 'Editar',
              icon: Icons.edit_rounded,
              onPressed: () => Navigator.pushNamed(context, '/usuarios/editar', arguments: user.id),
            ),
          ),
          const SizedBox(height: AdminSpacing.md),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 860;
                final profile = _ProfileBlock(user: user, lastAccess: _formatDate(user.lastAccess));
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

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: profile),
                    const SizedBox(width: AdminSpacing.md),
                    Expanded(child: data),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock({required this.user, required this.lastAccess});

  final AdminUser user;
  final String lastAccess;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AdminColors.navy,
            foregroundColor: AdminColors.selago,
            child: Text(
              user.initials,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AdminSpacing.md),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AdminColors.navy,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AdminSpacing.xs),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AdminSpacing.md),
          StatusChip(status: user.status),
          const SizedBox(height: AdminSpacing.md),
          _ProfileFact(icon: Icons.badge_rounded, label: 'Rol', value: user.role),
          _ProfileFact(icon: Icons.access_time_rounded, label: 'Ultima vez activo', value: lastAccess),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos de usuario',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AdminColors.navy,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AdminSpacing.lg),
          _DetailRow(icon: Icons.person_rounded, label: 'Nombre completo', value: user.name),
          _DetailRow(icon: Icons.credit_card_rounded, label: 'RUT', value: user.rut),
          _DetailRow(icon: Icons.phone_rounded, label: 'Numero', value: user.phone),
          _DetailRow(icon: Icons.home_rounded, label: 'Direccion principal', value: user.primaryAddress),
        ],
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  const _ProfileFact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminSpacing.xs),
      padding: const EdgeInsets.all(AdminSpacing.sm),
      decoration: BoxDecoration(
        color: AdminColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AdminColors.navy, size: 20),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700)),
                Text(value, style: const TextStyle(color: AdminColors.text, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AdminColors.selago,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AdminColors.navy),
          ),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AdminColors.text, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
