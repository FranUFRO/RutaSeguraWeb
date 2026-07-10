import 'package:flutter/material.dart';

import '../widgets/admin_theme.dart';
import '../services/api_client.dart';
import '../services/app_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _logoUrl =
      '../assets/images/logo_principal.png';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberSession = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppServices.auth.login(
        _emailController.text,
        _passwordController.text,
        _rememberSession,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'No fue posible conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.page,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 560 ? 20.0 : 40.0;
            final cardWidth = constraints.maxWidth < 860
                ? constraints.maxWidth - (horizontalPadding * 2)
                : 690.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: cardWidth,
                    minWidth: constraints.maxWidth < 360 ? 280 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 50,
                          offset: Offset(0, 25),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 102,
                            child: Image.network(
                              _logoUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const _RutaSeguraLogoFallback();
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AdminColors.navy,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ingresa a tu cuenta para continuar',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF43474E),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 40),
                          _LoginTextField(
                            label: 'Correo electrónico',
                            controller: _emailController,
                            hintText: 'nombre@ejemplo.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Ingresa tu correo electrónico.';
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                                return 'Ingresa un correo válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _PasswordField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Text(_error!, style: const TextStyle(color: AdminColors.danger)),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberSession,
                                  onChanged: (value) {
                                    setState(() => _rememberSession = value ?? false);
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(color: Color(0xFFC4C6CF)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Mantener sesión iniciada',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF43474E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              onPressed: _loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AdminColors.navy,
                                foregroundColor: AdminColors.selago,
                                elevation: 10,
                                shadowColor: AdminColors.navy.withValues(alpha: 0.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.45,
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Iniciar sesión'),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AdminColors.text,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AdminColors.muted),
            prefixIcon: Icon(icon, color: AdminColors.muted),
            filled: true,
            fillColor: AdminColors.field,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 19,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.navy, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Contraseña',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AdminColors.text,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AdminColors.navy,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          validator: (value) {
            if ((value ?? '').isEmpty) return 'Ingresa tu contraseña.';
            if ((value ?? '').length < 8) return 'Debe tener al menos 8 caracteres.';
            return null;
          },
          decoration: InputDecoration(
            hintText: '********',
            hintStyle: const TextStyle(color: AdminColors.muted),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AdminColors.muted),
            suffixIcon: IconButton(
              tooltip: obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AdminColors.muted,
              ),
            ),
            filled: true,
            fillColor: AdminColors.field,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 19,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.navy, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _RutaSeguraLogoFallback extends StatelessWidget {
  const _RutaSeguraLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.route_rounded, color: AdminColors.navy, size: 48),
        const SizedBox(height: 4),
        Text(
          'RUTA SEGURA',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AdminColors.navy,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
        ),
      ],
    );
  }
}
