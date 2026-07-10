import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
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
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  List<AdminUser> _users = const [];
  bool _loading = true;
  String? _error;
  AdminUserStatus? _statusFilter;
  String? _roleFilter;
  int _page = 0;

  bool get _hasFilters => _statusFilter != null || _roleFilter != null;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await AppServices.users.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _page = 0;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AdminUser> get _filteredUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _users.where((user) {
      final searchable = [
        user.name,
        user.email,
        user.rut,
        user.phone,
        user.organization,
        user.role,
        user.statusLabel,
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchable.contains(query);
      final matchesStatus = _statusFilter == null || user.status == _statusFilter;
      final matchesRole = _roleFilter == null || user.role == _roleFilter;
      return matchesQuery && matchesStatus && matchesRole;
    }).toList();
  }

  List<String> get _availableRoles {
    final roles = {
      'Administrador',
      'Supervisor',
      'Voluntario',
      for (final user in _users) user.role,
    }.where((role) => role.trim().isNotEmpty && role != 'Sin rol').toList()
      ..sort();
    return roles;
  }

  Future<void> _openCreateUser() async {
    final created = await Navigator.pushNamed(context, '/usuarios/crear');
    if (created == true || created == null) {
      await _loadUsers();
    }
  }

  Future<void> _openUserDetails(AdminUser user) async {
    await Navigator.pushNamed(context, '/usuarios/detalles', arguments: user.id);
    await _loadUsers();
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    var selectedStatus = _statusFilter;
    var selectedRole = _roleFilter;

    final result = await showDialog<({AdminUserStatus? status, String? role})>(
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
                    DropdownButtonFormField<AdminUserStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.toggle_on_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Todos los estados'),
                        ),
                        DropdownMenuItem(
                          value: AdminUserStatus.active,
                          child: Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value: AdminUserStatus.pending,
                          child: Text('Pendiente'),
                        ),
                        DropdownMenuItem(
                          value: AdminUserStatus.blocked,
                          child: Text('Bloqueado'),
                        ),
                      ],
                      onChanged: (value) => setDialogState(() => selectedStatus = value),
                    ),
                    const SizedBox(height: AdminSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        prefixIcon: Icon(Icons.badge_rounded),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todos los roles'),
                        ),
                        for (final role in _availableRoles)
                          DropdownMenuItem(value: role, child: Text(role)),
                      ],
                      onChanged: (value) => setDialogState(() => selectedRole = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, (status: null, role: null)),
                  child: const Text('Limpiar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      (status: selectedStatus, role: selectedRole),
                    );
                  },
                  child: const Text('Aplicar filtros'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    setState(() {
      _statusFilter = result.status;
      _roleFilter = result.role;
      _page = 0;
    });
  }

  Future<void> _showDeleteUserDialog(BuildContext context, AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que deseas eliminar este usuario?'),
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
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            user.email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AdminColors.muted),
                          ),
                          Text(
                            user.role,
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

    if (confirmed != true) return;

    try {
      await AppServices.users.deleteUser(user.id);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado correctamente.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;
    final pageCount = filtered.isEmpty ? 1 : (filtered.length / _pageSize).ceil();
    if (_page >= pageCount) _page = pageCount - 1;
    if (_page < 0) _page = 0;
    final pageUsers = filtered.skip(_page * _pageSize).take(_pageSize).toList();

    return AdminShell(
      title: 'Lista de usuarios',
      subtitle: 'Administra perfiles, roles y estados de acceso.',
      selectedRoute: AdminUserListScreen.routeName,
      child: Column(
        children: [
          _UsersToolbar(
            searchController: _searchController,
            onSearchChanged: (_) => setState(() => _page = 0),
            onCreateUser: _openCreateUser,
            onFilter: () => _showFilterDialog(context),
            hasFilters: _hasFilters,
          ),
          const SizedBox(height: AdminSpacing.md),
          Expanded(
            child: _UsersContent(
              loading: _loading,
              error: _error,
              users: pageUsers,
              onRetry: _loadUsers,
              onView: _openUserDetails,
              onDelete: (user) => _showDeleteUserDialog(context, user),
            ),
          ),
          const SizedBox(height: AdminSpacing.md),
          _UsersPagination(
            currentPage: _page,
            pageCount: pageCount,
            onPageChanged: (page) => setState(() => _page = page),
          ),
        ],
      ),
    );
  }
}

class _UsersToolbar extends StatelessWidget {
  const _UsersToolbar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreateUser,
    required this.onFilter,
    required this.hasFilters,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
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
            controller: searchController,
            onChanged: onSearchChanged,
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

class _UsersContent extends StatelessWidget {
  const _UsersContent({
    required this.loading,
    required this.error,
    required this.users,
    required this.onRetry,
    required this.onView,
    required this.onDelete,
  });

  final bool loading;
  final String? error;
  final List<AdminUser> users;
  final VoidCallback onRetry;
  final ValueChanged<AdminUser> onView;
  final ValueChanged<AdminUser> onDelete;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: AdminCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 46, color: AdminColors.danger),
              const SizedBox(height: AdminSpacing.sm),
              const Text('No se pudieron cargar los usuarios.'),
              const SizedBox(height: AdminSpacing.xs),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AdminColors.muted),
              ),
              const SizedBox(height: AdminSpacing.sm),
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

    if (users.isEmpty) {
      return const Center(
        child: AdminCard(
          child: Text(
            'No hay usuarios para mostrar.',
            style: TextStyle(color: AdminColors.muted, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: AdminSpacing.md),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListTileCard(
          user: user,
          onView: () => onView(user),
          onDelete: () => onDelete(user),
        );
      },
    );
  }
}

class _UsersPagination extends StatelessWidget {
  const _UsersPagination({
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
  });

  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final pages = _visiblePages();

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
            _PageButton(
              label: '<<',
              onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
            ),
            _PageButton(
              label: '<',
              onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            ),
            for (final item in pages)
              if (item == null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(color: AdminColors.muted)),
                )
              else
                _PageButton(
                  label: '${item + 1}',
                  selected: item == currentPage,
                  onPressed: item == currentPage ? null : () => onPageChanged(item),
                ),
            _PageButton(
              label: '>',
              onPressed: currentPage + 1 < pageCount ? () => onPageChanged(currentPage + 1) : null,
            ),
            _PageButton(
              label: '>>',
              onPressed: currentPage + 1 < pageCount ? () => onPageChanged(pageCount - 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  List<int?> _visiblePages() {
    if (pageCount <= 5) {
      return List.generate(pageCount, (index) => index);
    }

    final pages = <int?>[0];
    final start = (currentPage - 1).clamp(1, pageCount - 2).toInt();
    final end = (currentPage + 1).clamp(1, pageCount - 2).toInt();

    if (start > 1) pages.add(null);
    for (var page = start; page <= end; page++) {
      pages.add(page);
    }
    if (end < pageCount - 2) pages.add(null);
    pages.add(pageCount - 1);
    return pages;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onPressed;
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
            disabledForegroundColor: selected ? AdminColors.selago : AdminColors.muted,
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
