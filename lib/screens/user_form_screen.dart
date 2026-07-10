import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/admin_user.dart';
import '../services/app_services.dart';
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
  @override
  Widget build(BuildContext context) {
    return const _UserFormScaffold(initialUser: null);
  }
}

class _EditUserFormScreenState extends State<EditUserFormScreen> {
  late Future<AdminUser> _future = AppServices.users.getUserById(widget.userId);

  void _reload() {
    setState(() => _future = AppServices.users.getUserById(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminUser>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AdminShell(
            title: 'Formulario editar usuario',
            subtitle: 'Cargando datos del usuario.',
            selectedRoute: '/usuarios',
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return AdminShell(
            title: 'Formulario editar usuario',
            subtitle: 'No fue posible recuperar los datos.',
            selectedRoute: '/usuarios',
            child: Center(
              child: AdminCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 46, color: AdminColors.danger),
                    const SizedBox(height: AdminSpacing.sm),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AdminColors.muted),
                    ),
                    const SizedBox(height: AdminSpacing.md),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _UserFormScaffold(initialUser: snapshot.data!);
      },
    );
  }
}

class _UserFormScaffold extends StatefulWidget {
  const _UserFormScaffold({required this.initialUser});

  final AdminUser? initialUser;

  @override
  State<_UserFormScaffold> createState() => _UserFormScaffoldState();
}

class _UserFormScaffoldState extends State<_UserFormScaffold> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.initialUser?.name);
  late final _emailController = TextEditingController(text: widget.initialUser?.email);
  late final _rutController = TextEditingController(text: widget.initialUser?.rut);
  late final _phoneController = TextEditingController(text: widget.initialUser?.phone);
  late final _organizationController = TextEditingController(text: widget.initialUser?.organization);
  late final _passwordController = TextEditingController();
  late final _confirmPasswordController = TextEditingController();

  late String _role = widget.initialUser?.role ?? 'Voluntario';
  Uint8List? _certificateBytes;
  String? _certificateName;
  bool _saving = false;

  bool get _editing => widget.initialUser != null;
  bool get _requiresCertificate => !_editing && _role == 'Supervisor';
  bool get _requiresOrganization => _role == 'Supervisor';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rutController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null) return;

    final file = result.files.single;
    final fileName = file.name.toLowerCase();
    if (!fileName.endsWith('.pdf')) {
      _showMessage('El certificado debe ser un archivo PDF.');
      return;
    }
    if (file.size > 5 * 1024 * 1024) {
      _showMessage('El PDF no puede superar 5 MB.');
      return;
    }
    if (file.bytes == null || file.bytes!.isEmpty) {
      _showMessage('No fue posible leer el archivo seleccionado.');
      return;
    }

    setState(() {
      _certificateBytes = file.bytes;
      _certificateName = file.name;
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_requiresCertificate && _certificateBytes == null) {
      _showMessage('Selecciona el certificado PDF del supervisor.');
      return;
    }

    setState(() => _saving = true);

    try {
      if (_editing) {
        final current = widget.initialUser!;
        await AppServices.users.updateUser(
          AdminUser(
            id: current.id,
            name: _nameController.text.trim(),
            email: current.email,
            role: _role,
            phone: _phoneController.text.trim(),
            rut: current.rut,
            organization: _requiresOrganization ? _organizationController.text.trim() : '',
            status: current.status,
            primaryAddress: current.primaryAddress,
            lastAccess: current.lastAccess,
            createdAt: current.createdAt,
          ),
        );
      } else {
        await AppServices.users.createUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rut: _rutController.text.trim(),
          phone: _phoneController.text.trim(),
          organization: _requiresOrganization ? _organizationController.text.trim() : '',
          role: _role,
          certificateBytes: _certificateBytes,
          certificateName: _certificateName,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: _editing ? 'Formulario editar usuario' : 'Formulario crear usuario',
      subtitle: _editing ? 'Actualiza datos personales y rol del usuario.' : 'Completa la informacion de acceso y perfil.',
      selectedRoute: '/usuarios',
      child: SingleChildScrollView(
        child: AdminCard(
          padding: const EdgeInsets.all(AdminSpacing.md),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final profileFields = [
                  AdminTextField(
                    label: 'Nombre completo',
                    controller: _nameController,
                    icon: Icons.person_rounded,
                    validator: _required,
                  ),
                  AdminTextField(
                    label: 'Correo electronico',
                    controller: _emailController,
                    icon: Icons.mail_rounded,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: _editing,
                    validator: _emailValidator,
                  ),
                  AdminTextField(
                    label: 'RUT',
                    controller: _rutController,
                    icon: Icons.credit_card_rounded,
                    readOnly: _editing,
                    validator: _rutValidator,
                  ),
                  AdminTextField(
                    label: 'Telefono',
                    controller: _phoneController,
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  if (_requiresOrganization)
                    AdminTextField(
                      label: 'Organizacion',
                      controller: _organizationController,
                      icon: Icons.business_rounded,
                      validator: _required,
                    ),
                ];

                final passwordFields = [
                  AdminTextField(
                    label: 'Contrasena',
                    controller: _passwordController,
                    icon: Icons.lock_rounded,
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  AdminTextField(
                    label: 'Confirmar contrasena',
                    controller: _confirmPasswordController,
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: _confirmPasswordValidator,
                  ),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_editing) ...[
                      _RoleCards(
                        selectedRole: _role,
                        onRoleChanged: (value) {
                          setState(() {
                            _role = value;
                            if (_role != 'Supervisor') {
                              _certificateBytes = null;
                              _certificateName = null;
                              _organizationController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: AdminSpacing.md),
                    ],
                    _FieldGrid(fields: profileFields, wide: wide),
                    if (!_editing) ...[
                      const SizedBox(height: AdminSpacing.sm),
                      _FieldGrid(fields: passwordFields, wide: wide),
                    ],
                    if (_requiresCertificate) ...[
                      const SizedBox(height: AdminSpacing.sm),
                      _CertificatePicker(
                        fileName: _certificateName,
                        onPick: _saving ? null : _pickCertificate,
                      ),
                    ],
                    const SizedBox(height: AdminSpacing.md),
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
                            onPressed: _saving ? null : () => Navigator.pop(context),
                          ),
                          _FormActionButton(
                            label: _editing ? 'Guardar cambios' : 'Crear usuario',
                            icon: Icons.check_rounded,
                            backgroundColor: AdminColors.navy,
                            foregroundColor: AdminColors.selago,
                            loading: _saving,
                            onPressed: _saving ? null : _submit,
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

  String? _required(String? value) {
    return (value ?? '').trim().isEmpty ? 'Campo obligatorio.' : null;
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Campo obligatorio.';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email) ? null : 'Correo invalido.';
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Campo obligatorio.';
    if (password.length < 8) return 'Minimo 8 caracteres.';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'Campo obligatorio.';
    return value == _passwordController.text ? null : 'Las contrasenas no coinciden.';
  }

  String? _rutValidator(String? value) {
    final rut = (value ?? '').trim();
    if (rut.isEmpty) return 'Campo obligatorio.';
    return _validRut(rut) ? null : 'RUT invalido.';
  }

  bool _validRut(String input) {
    final rut = input.replaceAll('.', '').replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^\d{7,8}-[\dK]$').hasMatch(rut)) return false;
    final parts = rut.split('-');
    var sum = 0;
    var multiplier = 2;
    for (var index = parts[0].length - 1; index >= 0; index--) {
      sum += int.parse(parts[0][index]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }
    final digit = 11 - (sum % 11);
    final expected = digit == 11
        ? '0'
        : digit == 10
            ? 'K'
            : '$digit';
    return parts[1] == expected;
  }
}

class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.fields, required this.wide});

  final List<Widget> fields;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            fields[index],
            if (index != fields.length - 1) const SizedBox(height: AdminSpacing.sm),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AdminSpacing.sm) / 2;
        return Wrap(
          spacing: AdminSpacing.sm,
          runSpacing: AdminSpacing.sm,
          children: [
            for (final field in fields) SizedBox(width: itemWidth, child: field),
          ],
        );
      },
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
      padding: const EdgeInsets.all(AdminSpacing.md),
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
          const SizedBox(height: AdminSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;
              final cards = [
                _RoleOptionCard(
                  title: 'Administrador',
                  description: 'Gestiona usuarios, revisa solicitudes y administra la plataforma.',
                  icon: Icons.admin_panel_settings_rounded,
                  selected: selectedRole == 'Administrador',
                  onTap: () => onRoleChanged('Administrador'),
                ),
                _RoleOptionCard(
                  title: 'Supervisor',
                  description: 'Coordina rutas, equipos y requiere certificado PDF para su alta.',
                  icon: Icons.supervisor_account_rounded,
                  selected: selectedRole == 'Supervisor',
                  onTap: () => onRoleChanged('Supervisor'),
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
                    for (var index = 0; index < cards.length; index++) ...[
                      SizedBox(height: 112, child: cards[index]),
                      if (index != cards.length - 1) const SizedBox(height: AdminSpacing.sm),
                    ],
                  ],
                );
              }

              return SizedBox(
                height: 112,
                child: Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: AdminSpacing.sm),
                    Expanded(child: cards[1]),
                    const SizedBox(width: AdminSpacing.sm),
                    Expanded(child: cards[2]),
                  ],
                ),
              );
            },
          ),
        ],
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
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(14),
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
                  Icon(icon, color: AdminColors.navy, size: 22),
                  _SelectionIndicator(selected: selected),
                ],
              ),
              const SizedBox(height: AdminSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AdminColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      width: 20,
      height: 20,
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

class _CertificatePicker extends StatelessWidget {
  const _CertificatePicker({
    required this.fileName,
    required this.onPick,
  });

  final String? fileName;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AdminSpacing.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: AdminColors.danger),
          ),
          const SizedBox(width: AdminSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Certificado PDF del supervisor',
                  style: TextStyle(color: AdminColors.text, fontWeight: FontWeight.w800),
                ),
                Text(
                  fileName ?? 'Archivo obligatorio. Maximo 5 MB.',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AdminColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AdminSpacing.sm),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(fileName == null ? 'Seleccionar' : 'Cambiar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.navy,
              side: const BorderSide(color: AdminColors.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
      width: 158,
      height: 42,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.55),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.85),
          padding: const EdgeInsets.symmetric(horizontal: AdminSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
