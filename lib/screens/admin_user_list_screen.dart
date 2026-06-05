import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  static const String routeName = '/usuarios';

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  String? _statusFilter;
  String? _roleFilter;

  @override
  Widget build(BuildContext context) {
    final users = const AdminUserService().getUsers().where(_matchesFilters).toList();

    return AdminShell(
      title: 'Lista de usuarios',
      subtitle: 'Administra perfiles, roles y estados de acceso.',
      selectedRoute: AdminUserListScreen.routeName,
      child: Column(
        children: [
          _UsersToolbar(
            onCreateUser: () => Navigator.pushNamed(context, '/usuarios/crear'),
            onFilter: () => _showFilterDialog(context),
            hasFilters: _statusFilter != null || _roleFilter != null,
          ),
          const SizedBox(height: AdminSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: AdminSpacing.md),
              itemBuilder: (context, index) {
                final user = users[index];
                return UserListTileCard(
                  user: user,
                  onView: () => Navigator.pushNamed(context, '/usuarios/detalles', arguments: user.id),
                  onDelete: () => _showDeleteUserDialog(context, user),
                );
              },
            ),
          ),
          const SizedBox(height: AdminSpacing.md),
          const _UsersPagination(),
        ],
      ),
    );
  }

  bool _matchesFilters(AdminUser user) {
    final matchesStatus = switch (_statusFilter) {
      null => true,
      'Activo' => user.status == AdminUserStatus.active,
      'Inactivo' => user.status == AdminUserStatus.pending,
      'Bloqueado' => user.status == AdminUserStatus.blocked,
      _ => true,
    };
    final matchesRole = _roleFilter == null || user.role == _roleFilter;
    return matchesStatus && matchesRole;
  }

  Future<void> _showFilterDialog(BuildContext context) {
    var selectedStatus = _statusFilter;
    var selectedRole = _roleFilter;
    final roles = const AdminUserService().getUsers().map((user) => user.role).toSet().toList()..sort();

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Filtrar usuarios'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.toggle_on_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                        DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                        DropdownMenuItem(value: 'Bloqueado', child: Text('Bloqueado')),
                      ],
                      onChanged: (value) => setDialogState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: AdminSpacing.md),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      items: [
                        for (final role in roles) DropdownMenuItem(value: role, child: Text(role)),
                      ],
                      onChanged: (value) => setDialogState(() => selectedRole = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _statusFilter = null;
                      _roleFilter = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _statusFilter = selectedStatus;
                      _roleFilter = selectedRole;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteUserDialog(BuildContext context, AdminUser user) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estas seguro de que deseas eliminar este usuario?'),
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
                      child: Text(user.initials),
                    ),
                    const SizedBox(width: AdminSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(user.email, style: const TextStyle(color: AdminColors.muted)),
                          Text(user.role, style: const TextStyle(color: AdminColors.navy, fontWeight: FontWeight.w700)),
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
                onPressed: () => Navigator.pop(context),
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.delete_rounded),
                label: const Text('Eliminar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.danger,
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
}

class _UsersToolbar extends StatelessWidget {
  const _UsersToolbar({
    required this.onCreateUser,
    required this.onFilter,
    required this.hasFilters,
  });

  final VoidCallback onCreateUser;
  final VoidCallback onFilter;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final search = SizedBox(
          width: compact ? double.infinity : 260,
          height: 48,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuario',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AdminColors.field,
              contentPadding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );

        final actions = Wrap(
          spacing: AdminSpacing.sm,
          runSpacing: AdminSpacing.sm,
          alignment: WrapAlignment.end,
          children: [
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onFilter,
                icon: const Icon(Icons.filter_list_rounded),
                label: const Text('Filtrar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.navy,
                  backgroundColor: hasFilters ? AdminColors.selago : Colors.transparent,
                  side: BorderSide(color: hasFilters ? AdminColors.navy : AdminColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            PrimaryAdminButton(
              label: 'Nuevo usuario',
              icon: Icons.person_add_alt_1_rounded,
              onPressed: onCreateUser,
            ),
          ],
        );

        final toolbar = AdminCard(
          padding: const EdgeInsets.all(AdminSpacing.md),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: AdminSpacing.sm),
                    actions,
                  ],
                )
              : Row(
                  children: [
                    search,
                    const SizedBox(width: AdminSpacing.md),
                    Flexible(child: actions),
                  ],
                ),
        );

        return Align(
          alignment: Alignment.centerRight,
          child: compact
              ? toolbar
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 610),
                  child: toolbar,
                ),
        );
      },
    );
  }
}

class _UsersPagination extends StatelessWidget {
  const _UsersPagination();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AdminCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AdminSpacing.sm,
          vertical: AdminSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageButton(label: '<<', onPressed: () {}),
            _PageButton(label: '<', onPressed: () {}),
            _PageButton(label: '1', selected: true, onPressed: () {}),
            _PageButton(label: '2', onPressed: () {}),
            _PageButton(label: '3', onPressed: () {}),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('...', style: TextStyle(color: AdminColors.muted)),
            ),
            _PageButton(label: '>', onPressed: () {}),
            _PageButton(label: '>>', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 30,
        height: 30,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: selected ? AdminColors.navy : Colors.transparent,
            foregroundColor: selected ? AdminColors.selago : AdminColors.navy,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
