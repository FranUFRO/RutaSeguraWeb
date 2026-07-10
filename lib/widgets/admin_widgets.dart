import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import 'admin_theme.dart';

class AdminCard extends StatelessWidget {
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AdminSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AdminColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14002045),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryAdminButton extends StatelessWidget {
  const PrimaryAdminButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AdminColors.navy,
        foregroundColor: AdminColors.selago,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AdminSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AdminColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AdminColors.muted,
                        fontWeight: FontWeight.w600,
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

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final AdminUserStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AdminUserStatus.active => ('Activo', AdminColors.success),
      AdminUserStatus.pending => ('Pendiente', AdminColors.warning),
      AdminUserStatus.blocked => ('Bloqueado', AdminColors.danger),
    };

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}

class UserListTileCard extends StatelessWidget {
  const UserListTileCard({
    super.key,
    required this.user,
    required this.onView,
    required this.onDelete,
  });

  final AdminUser user;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final identity = Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AdminColors.navy,
                foregroundColor: AdminColors.selago,
                child: Text(user.initials),
              ),
              const SizedBox(width: AdminSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AdminColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AdminColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _UserActionIconButton(
                  tooltip: 'Ver usuario',
                  icon: Icons.visibility_rounded,
                  color: AdminColors.navy,
                  onPressed: onView,
                ),
                const SizedBox(width: AdminSpacing.xs),
                _UserActionIconButton(
                  tooltip: 'Eliminar usuario',
                  icon: Icons.delete_rounded,
                  color: AdminColors.danger,
                  onPressed: onDelete,
                ),
              ],
            ),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: AdminSpacing.md),
                Row(
                  children: [
                    StatusChip(status: user.status),
                    const Spacer(),
                    actions,
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: identity),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(user.role, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(width: 116, child: Align(alignment: Alignment.centerLeft, child: StatusChip(status: user.status))),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        },
      ),
    );
  }
}

class _UserActionIconButton extends StatelessWidget {
  const _UserActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminTextField extends StatelessWidget {
  const AdminTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        filled: true,
        fillColor: readOnly ? AdminColors.line.withValues(alpha: 0.55) : AdminColors.field,
        suffixIcon: readOnly ? const Icon(Icons.lock_rounded, size: 18) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.navy, width: 1.4),
        ),
      ),
    );
  }
}
