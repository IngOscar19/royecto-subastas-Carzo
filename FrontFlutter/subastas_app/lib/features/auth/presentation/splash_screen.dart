import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/logo_badge.dart';

/// Splash de marca: gradiente oscuro, logo pulsante y tagline.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              ScaleTransition(
                scale: _scale,
                child: const LogoBadge(size: 96),
              ),
              const SizedBox(height: 28),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: AppFonts.headline,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                  children: [
                    TextSpan(text: 'CAR', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'ZO', style: TextStyle(color: AppColors.secondary)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _rule(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'AUTOS EN TIEMPO REAL',
                      style: TextStyle(
                        fontFamily: AppFonts.label,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: AppColors.secondary.withAlpha(230),
                      ),
                    ),
                  ),
                  _rule(),
                ],
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Restaurando sesión…',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: Colors.white.withAlpha(150),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rule() => Container(
        width: 26,
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(140),
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
