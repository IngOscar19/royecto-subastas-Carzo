import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/logo_badge.dart';
import '../domain/auth_failure.dart';
import '../domain/user_role.dart';
import 'auth_controller.dart';

/// Registro con selector de rol tipo tarjeta y medidor de contraseña.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.bidder;
  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final rawPhone = _phoneController.text.trim();
      final phone = rawPhone.isNotEmpty ? rawPhone : null;
      await ref.read(authControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _role,
            phone: phone,
          );
    } on AuthFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      failure.uiMessage,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    if (!email.contains('@')) {
      return 'Falta el símbolo "@" (ejemplo: usuario@correo.com)';
    }
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) {
      return 'Ingresa el nombre de usuario antes del "@" (ejemplo: juan@...)';
    }
    if (parts[1].isEmpty) {
      return 'Ingresa el proveedor después del "@" (ejemplo: ...@gmail.com)';
    }
    if (!parts[1].contains('.')) {
      return 'El correo debe tener una extensión de dominio (ejemplo: .com o .net)';
    }
    final domainParts = parts[1].split('.');
    if (domainParts.any((p) => p.isEmpty) || domainParts.last.length < 2) {
      return 'Extensión de correo no válida (ejemplo: .com, .es, .mx)';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Formato de correo no válido. Usa un correo real (ejemplo: juan@gmail.com)';
    }
    return null;
  }

  // ------------------------------------------------------------------
  // Medidor de fortaleza de contraseña

  int get _strength {
    final password = _passwordController.text;
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score.clamp(1, 4);
  }

  (Color, String) get _strengthData => switch (_strength) {
        0 => (AppColors.border, ''),
        1 => (const Color(0xFFEF4444), 'Débil'),
        2 => (const Color(0xFFF59E0B), 'Aceptable'),
        3 => (const Color(0xFF0284C7), 'Buena'),
        _ => (const Color(0xFF10B981), 'Excelente'),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppNavBar(
          title: 'Crear cuenta',
          subtitle: 'Únete a la casa de subastas',
          icon: Icons.person_add_outlined,
          showBackButton: true,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              const _RoleHeader(),
              const SizedBox(height: 18),
              _buildRoleCards(),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('Nombre completo'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: 'Juan Pérez',
                        prefixIcon:
                            Icon(Icons.person_outline, color: AppColors.neutral),
                      ),
                      validator: (value) =>
                          (value ?? '').trim().isEmpty ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Correo electrónico'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        _EmailCharacterFormatter(),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'ejemplo@subastas.com',
                        prefixIcon:
                            Icon(Icons.email_outlined, color: AppColors.neutral),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Número de teléfono (WhatsApp / Llamadas)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        hintText: '55 1234 5678',
                        prefixIcon:
                            Icon(Icons.phone_outlined, color: AppColors.neutral),
                        prefixText: '+52 ',
                        prefixStyle: TextStyle(
                          fontFamily: AppFonts.label,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        helperText:
                            'Requerido para coordinar entrega si ganas la subasta',
                        helperStyle:
                            TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        final digits =
                            (value ?? '').replaceAll(RegExp(r'\D'), '');
                        if (digits.isEmpty) {
                          return 'Ingresa tu número telefónico a 10 dígitos';
                        }
                        if (digits.length != 10) {
                          return 'El número debe tener 10 dígitos (ej. 55 1234 5678)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Contraseña'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [
                        _EmailCharacterFormatter(),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Mínimo 8 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.neutral),
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
                      validator: (value) => (value ?? '').length < 8
                          ? 'Mínimo 8 caracteres'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 10),
                    _buildStrengthMeter(),
                    const SizedBox(height: 24),
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
                            : const Icon(Icons.person_add_alt_1_rounded,
                                size: 20),
                        label: Text(
                          _submitting ? 'Creando cuenta…' : 'Crear mi cuenta',
                          style: const TextStyle(
                            fontFamily: AppFonts.headline,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _submitting ? null : () => context.go('/login'),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    final (color, label) = _strengthData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < _strength ? color : AppColors.border.withAlpha(90),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (i < 3) const SizedBox(width: 6),
            ],
          ],
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Fortaleza: $label',
            style: TextStyle(
              fontFamily: AppFonts.label,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color == AppColors.border
                  ? AppColors.textSecondary
                  : color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoleCards() {
    return Row(
      children: [
        Expanded(child: _roleCard(UserRole.bidder)),
        const SizedBox(width: 12),
        Expanded(child: _roleCard(UserRole.seller)),
      ],
    );
  }

  Widget _roleCard(UserRole role) {
    final selected = _role == role;
    final isBidder = role == UserRole.bidder;
    final accent = isBidder ? AppColors.secondary : AppColors.primary;

    return InkWell(
      onTap: () => setState(() => _role = role),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              selected ? accent.withAlpha(22) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accent.withAlpha(30)
                  : const Color(0x0C0F172A),
              blurRadius: selected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: selected ? accent : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isBidder ? Icons.gavel_rounded : Icons.sell_outlined,
                    size: 20,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? accent : AppColors.textLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              role.label,
              style: TextStyle(
                fontFamily: AppFonts.headline,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: selected ? accent : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isBidder
                  ? 'Puja en subastas en vivo y gana vehículos'
                  : 'Publica tus autos y gestiona subastas',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11.5,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LogoBadge(size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige cómo participar',
                style: TextStyle(
                  fontFamily: AppFonts.headline,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Podrás cambiar tu experiencia según tu rol',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  color: AppColors.textSecondary.withAlpha(230),
                ),
              ),
            ],
          ),
        ),
      ],
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

/// Corrige automáticamente el caracter especial 'œ' / 'Œ' por '@' si el usuario
/// escribe Option+Q en teclado macOS.
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
