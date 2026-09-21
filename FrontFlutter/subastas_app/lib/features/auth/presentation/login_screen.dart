import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/logo_badge.dart';
import '../domain/auth_failure.dart';
import 'auth_controller.dart';

/// Login con panel de marca superior y hoja de formulario.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(failure.uiMessage)),
              ],
            ),
            backgroundColor: AppColors.tertiary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const _BrandHeader(),
                  const Spacer(),
                  _buildFormSheet(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hoja blanca redondeada con el formulario de acceso.
  Widget _buildFormSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(26, 30, 26, 34),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido de nuevo',
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ingresa tus credenciales para continuar',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 26),
            const _FieldLabel('Correo electrónico'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                _EmailCharacterFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'ejemplo@subastas.com',
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppColors.neutral),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Ingresa tu email';
                if (!email.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Contraseña'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                _EmailCharacterFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon:
                    const Icon(Icons.lock_outline, color: AppColors.neutral),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.neutral,
                  ),
                ),
              ),
              validator: (value) =>
                  (value ?? '').isEmpty ? 'Ingresa tu contraseña' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.login_rounded, size: 20),
                label: Text(
                  _submitting ? 'Ingresando…' : 'Iniciar sesión',
                  style: const TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: _submitting ? null : () => context.go('/register'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                  child: const Text(
                    'Regístrate gratis',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.headline,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Panel superior oscuro con logo, nombre y beneficios de la plataforma.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
      child: Column(
        children: [
          const LogoBadge(size: 84),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
              children: [
                TextSpan(text: 'CAR', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'ZO', style: TextStyle(color: AppColors.secondary)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'La casa de subastas de autos #1',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 14,
              color: AppColors.border.withAlpha(220),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _feature(Icons.bolt_rounded, 'Puja en vivo'),
              const SizedBox(width: 18),
              _feature(Icons.verified_user_outlined, '100% seguro'),
              const SizedBox(width: 18),
              _feature(Icons.emoji_events_outlined, 'Gana tu auto'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _feature(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _EmailCharacterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final fixedText = newValue.text.replaceAll('œ', '@').replaceAll('Œ', '@');
    if (fixedText == newValue.text) {
      return newValue;
    }
    return newValue.copyWith(
      text: fixedText,
      selection: TextSelection.collapsed(
        offset: newValue.selection.end.clamp(0, fixedText.length),
      ),
    );
  }
}
