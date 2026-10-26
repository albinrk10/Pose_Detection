import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/exercise_metrics.dart';
import '../../domain/entities/exercise_stage.dart';

class ModernCounterOverlay extends StatelessWidget {
  final ExerciseMetrics metrics;
  final VoidCallback onReset;
  final VoidCallback onBack;
  final VoidCallback onSwitchCamera;

  const ModernCounterOverlay({
    super.key,
    required this.metrics,
    required this.onReset,
    required this.onBack,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Barra de controles superiores
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circularGlassButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                _circularGlassButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onTap: onSwitchCamera,
                ),
                _circularGlassButton(
                  icon: Icons.refresh_rounded,
                  onTap: () => _showResetDialog(context),
                ),
              ],
            ),
          ),

          // Tarjeta central superior de Métricas (Glassmorphism)
          Positioned(
            top: 76,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Contador de repeticiones
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${metrics.repetitions}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryNeon,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.repsCounterLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),

                      // Separador vertical
                      Container(
                        height: 48,
                        width: 1.5,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),

                      // Ángulo de codo
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            metrics.activeArm == DetectedArm.none
                                ? '--°'
                                : '${metrics.currentAngle.toStringAsFixed(0)}°',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _getAngleColor(metrics.currentAngle),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.elbowAngleLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Banner de retroalimentación inferior (Feedback en tiempo real)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryNeon.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        metrics.stage == ExerciseStage.down
                            ? Icons.arrow_downward_rounded
                            : Icons.fitness_center_rounded,
                        color: AppTheme.primaryNeon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          metrics.feedbackMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAngleColor(double angle) {
    if (angle <= 90) {
      return AppTheme.primaryNeon; // Buen descenso
    } else if (angle <= 140) {
      return AppTheme.accentOrange; // En descenso/ascenso
    } else {
      return AppTheme.secondaryCyan; // Extendido
    }
  }

  Widget _circularGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(AppStrings.resetConfirmTitle),
        content: const Text(AppStrings.resetConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNeon,
              foregroundColor: Colors.black,
            ),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
