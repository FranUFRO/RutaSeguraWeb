import 'package:flutter/material.dart';

import 'admin_theme.dart';
import '../services/app_services.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedRoute,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final String selectedRoute;
  final Widget child;
  final List<Widget> actions;

  static const double _sidebarWidth = 260;
  static const double _maxContentWidth = 1180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.page,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 920;
            final content = Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? AdminSpacing.lg : AdminSpacing.md,
                    AdminSpacing.md,
                    isWide ? AdminSpacing.lg : AdminSpacing.md,
                    isWide ? AdminSpacing.lg : AdminSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PageHeader(title: title, subtitle: subtitle, actions: actions),
                      const SizedBox(height: AdminSpacing.md),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            );

            if (!isWide) {
              return Column(
                children: [
                  const _TopBar(showBrand: true),
                  _MobileNavigation(selectedRoute: selectedRoute),
                  Expanded(child: content),
                ],
              );
            }

            return Column(
              children: [
                const _TopBar(showBrand: false),
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: _sidebarWidth,
                        child: _Sidebar(selectedRoute: selectedRoute),
                      ),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.showBrand});

  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.lg),
      decoration: BoxDecoration(
        color: AdminColors.surface.withValues(alpha: 0.86),
        border: const Border(bottom: BorderSide(color: AdminColors.line)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1E3A8A),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBrand) ...[
            const _Brand(compact: true),
            const SizedBox(width: AdminSpacing.lg),
          ],
          const Flexible(child: _AdminIdentity()),
          const Spacer(),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AdminColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AdminSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AdminColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        );

        if (compact) {
          if (actions.isEmpty) {
            return text;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: text),
              const SizedBox(width: AdminSpacing.sm),
              Align(
                alignment: Alignment.topRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AdminSpacing.sm,
                  runSpacing: AdminSpacing.sm,
                  children: actions,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: text),
            Align(
              alignment: Alignment.topRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AdminSpacing.sm,
                runSpacing: AdminSpacing.sm,
                children: actions,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedRoute});

  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AdminSpacing.md),
      padding: const EdgeInsets.all(AdminSpacing.md),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(compact: false),
          const SizedBox(height: AdminSpacing.xl),
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            route: '/dashboard',
            selectedRoute: selectedRoute,
          ),
          _NavItem(
            icon: Icons.people_alt_rounded,
            label: 'Usuarios',
            route: '/usuarios',
            selectedRoute: selectedRoute,
          ),
          _NavItem(
            icon: Icons.verified_user_rounded,
            label: 'Verificar',
            route: '/verificar',
            selectedRoute: selectedRoute,
          ),
          const Spacer(),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({required this.selectedRoute});

  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AdminSpacing.md, AdminSpacing.md, AdminSpacing.md, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: AdminSpacing.sm,
        vertical: AdminSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _IconNavButton(
              icon: Icons.home_rounded,
              route: '/dashboard',
              label: 'Inicio',
              selectedRoute: selectedRoute,
            ),
          ),
          Expanded(
            child: _IconNavButton(
              icon: Icons.people_alt_rounded,
              route: '/usuarios',
              label: 'Usuarios',
              selectedRoute: selectedRoute,
            ),
          ),
          Expanded(
            child: _IconNavButton(
              icon: Icons.verified_user_rounded,
              route: '/verificar',
              label: 'Verificar',
              selectedRoute: selectedRoute,
            ),
          ),
          Expanded(
            child: _IconNavButton(
              icon: Icons.logout_rounded,
              route: '/',
              label: 'Salir',
              selectedRoute: selectedRoute,
              replaceStack: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      'Ruta Segura',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (compact
              ? Theme.of(context).textTheme.titleMedium
              : Theme.of(context).textTheme.titleLarge)
          ?.copyWith(
        color: AdminColors.navy,
        fontWeight: FontWeight.w800,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 32 : 48,
          height: compact ? 32 : 48,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 252, 252, 252),
            borderRadius: BorderRadius.circular(compact ? 10 : 16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 10 : 16),
            child: Image.asset(
              'assets/images/logo_minimalista.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: AdminSpacing.sm),
        if (compact) SizedBox(width: 104, child: text) else text,
      ],
    );
  }
}

class _AdminIdentity extends StatelessWidget {
  const _AdminIdentity();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppServices.auth,
      builder: (context, _) {
        final user = AppServices.auth.user;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? 'Administrador',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AdminColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              'Administrador',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AdminColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.selectedRoute,
  });

  final IconData icon;
  final String label;
  final String route;
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    final selected = selectedRoute == route;
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminSpacing.xs),
      child: Material(
        color: selected ? AdminColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushReplacementNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md, vertical: AdminSpacing.sm),
            child: Row(
              children: [
                Icon(icon, color: selected ? AdminColors.selago : AdminColors.navy),
                const SizedBox(width: AdminSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? AdminColors.selago : AdminColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconNavButton extends StatelessWidget {
  const _IconNavButton({
    required this.icon,
    required this.route,
    required this.label,
    required this.selectedRoute,
    this.replaceStack = false,
  });

  final IconData icon;
  final String route;
  final String label;
  final String selectedRoute;
  final bool replaceStack;

  @override
  Widget build(BuildContext context) {
    final selected = selectedRoute == route;
    return Tooltip(
      message: label,
      child: IconButton.filledTonal(
        isSelected: selected,
        onPressed: () {
          if (replaceStack) {
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
            return;
          }
          Navigator.pushReplacementNamed(context, route);
        },
        icon: Icon(icon),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.field,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await AppServices.auth.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminSpacing.md,
            vertical: AdminSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AdminColors.danger),
              const SizedBox(width: AdminSpacing.sm),
              Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AdminColors.danger,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
