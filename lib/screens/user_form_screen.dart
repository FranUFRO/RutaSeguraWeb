import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_theme.dart';
import '../widgets/admin_widgets.dart';

class CreateUserFormScreen extends StatefulWidget {
  const CreateUserFormScreen({super.key});

  static const String routeName = '/usuarios/crear';

  @override
  State<CreateUserFormScreen> createState() => _CreateUserFormScreenState();
}

class EditUserFormScreen extends StatefulWidget {
  const EditUserFormScreen({super.key, required this.userId});

  static const String routeName = '/usuarios/editar';

  final String userId;

  @override
  State<EditUserFormScreen> createState() => _EditUserFormScreenState();
}

class _CreateUserFormScreenState extends State<CreateUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _organizationController = TextEditingController();
  String _role = 'Voluntario';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _UserFormScaffold(
      title: 'Formulario crear usuario',
      subtitle: 'Completa la informacion de acceso y perfil.',
      submitLabel: 'Crear usuario',
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      organizationController: _organizationController,
      organizationReadOnly: false,
      role: _role,
      onRoleChanged: (value) => setState(() => _role = value),
      onSubmit: () => Navigator.pushReplacementNamed(context, '/usuarios'),
    );
  }
}

class _EditUserFormScreenState extends State<EditUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminUser _user = const AdminUserService().getUserById(widget.userId);
  late final _nameController = TextEditingController(text: _user.name);
  late final _emailController = TextEditingController(text: _user.email);
  late final _phoneController = TextEditingController(text: _user.phone);
  late final _organizationController = TextEditingController(text: _user.organization);
  late String _role = _user.role == 'Administrador' || _user.role == 'Admin' ? 'Administrador' : 'Voluntario';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _UserFormScaffold(
      title: 'Formulario editar usuario',
      subtitle: 'Actualiza datos personales y rol del usuario.',
      submitLabel: 'Guardar cambios',
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      phoneController: _phoneController,
      organizationController: _organizationController,
      organizationReadOnly: true,
      role: _role,
      onRoleChanged: (value) => setState(() => _role = value),
      onSubmit: () => Navigator.pushReplacementNamed(context, '/usuarios/detalles', arguments: _user.id),
    );
  }
}

class _UserFormScaffold extends StatelessWidget {
  const _UserFormScaffold({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.organizationController,
    required this.organizationReadOnly,
    required this.role,
    required this.onRoleChanged,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController organizationController;
  final bool organizationReadOnly;
  final String role;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: title,
      subtitle: subtitle,
      selectedRoute: '/usuarios',
      child: SingleChildScrollView(
        child: AdminCard(
          child: Form(
            key: formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final fields = [
                  AdminTextField(
                    label: 'Nombre completo',
                    controller: nameController,
                    icon: Icons.person_rounded,
                  ),
                  AdminTextField(
                    label: 'Correo electronico',
                    controller: emailController,
                    icon: Icons.mail_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AdminTextField(
                    label: 'Telefono',
                    controller: phoneController,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  AdminTextField(
                    label: 'Organizacion',
                    controller: organizationController,
                    icon: Icons.business_rounded,
                    readOnly: organizationReadOnly,
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: AdminSpacing.md),
                          Expanded(child: fields[1]),
                        ],
                      )
                    else
                      fields[0],
                    const SizedBox(height: AdminSpacing.md),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields[2]),
                          const SizedBox(width: AdminSpacing.md),
                          Expanded(child: fields[3]),
                        ],
                      )
                    else ...[
                      fields[1],
                      const SizedBox(height: AdminSpacing.md),
                      fields[2],
                      const SizedBox(height: AdminSpacing.md),
                      fields[3],
                    ],
                    const SizedBox(height: AdminSpacing.md),
                    _RoleCards(
                      selectedRole: role,
                      onRoleChanged: onRoleChanged,
                    ),
                    const SizedBox(height: AdminSpacing.lg),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: AdminSpacing.sm,
                        runSpacing: AdminSpacing.sm,
                        children: [
                          _FormActionButton(
                            label: 'Cancelar',
                            icon: Icons.close_rounded,
                            backgroundColor: AdminColors.selago,
                            foregroundColor: AdminColors.navy,
                            onPressed: () => Navigator.pop(context),
                          ),
                          _FormActionButton(
                            label: submitLabel,
                            icon: Icons.check_rounded,
                            backgroundColor: AdminColors.navy,
                            foregroundColor: AdminColors.selago,
                            onPressed: onSubmit,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCards extends StatelessWidget {
  const _RoleCards({
    required this.selectedRole,
    required this.onRoleChanged,
  });

  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona el rol del usuario',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AdminColors.muted,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AdminSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 640;
              final cards = [
                _RoleOptionCard(
                  title: 'Administrador',
                  description: 'Gestiona usuarios, revisa solicitudes y administra la plataforma.',
                  icon: Icons.admin_panel_settings_rounded,
                  selected: selectedRole == 'Administrador',
                  onTap: () => onRoleChanged('Administrador'),
                ),
                _RoleOptionCard(
                  title: 'Voluntario',
                  description: 'Accede a funciones operativas y apoyo en actividades de seguridad.',
                  icon: Icons.volunteer_activism_rounded,
                  selected: selectedRole == 'Voluntario',
                  onTap: () => onRoleChanged('Voluntario'),
                ),
              ];

              if (!wide) {
                return Column(
                  children: [
                    cards[0],
                    const SizedBox(height: AdminSpacing.md),
                    cards[1],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: AdminSpacing.md),
                  Expanded(child: cards[1]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FormActionButton extends StatelessWidget {
  const _FormActionButton({
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
      width: 176,
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.selago : AdminColors.field,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 165),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AdminColors.navy : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: AdminColors.navy, size: 28),
                  _SelectionIndicator(selected: selected),
                ],
              ),
              const SizedBox(height: AdminSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AdminColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF43474E),
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AdminColors.navy : const Color(0xFFC4C6CF),
          width: 2,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? AdminColors.navy : Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
