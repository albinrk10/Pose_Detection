import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import 'home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final animationSize = math.min(size.width * 0.65, 260.0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación Lottie de Flexiones
                Container(
                  alignment: Alignment.center,
                  width: animationSize,
                  height: animationSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface.withValues(alpha: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNeon.withValues(alpha: 0.12),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Lottie.asset(
                    'assets/push-up-animation.json',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // Título en español
                const Text(
                  AppStrings.splashTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtítulo
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    AppStrings.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Botón Principal
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNeon,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.startNow,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
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
