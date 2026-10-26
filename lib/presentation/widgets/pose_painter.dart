import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/coordinates_translator.dart';
import '../../domain/entities/exercise_stage.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final DetectedArm activeArm;

  PosePainter({
    required this.poses,
    required this.imageSize,
    required this.rotation,
    required this.cameraLensDirection,
    this.activeArm = DetectedArm.none,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Si no hay poses o no se ha validado un cuerpo humano real, no pintar nada
    if (poses.isEmpty || activeArm == DetectedArm.none) return;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.white54;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = activeArm == DetectedArm.left ? 5.0 : 3.0
      ..color = activeArm == DetectedArm.left
          ? AppTheme.primaryNeon
          : AppTheme.secondaryCyan.withValues(alpha: 0.6);

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = activeArm == DetectedArm.right ? 5.0 : 3.0
      ..color = activeArm == DetectedArm.right
          ? AppTheme.primaryNeon
          : Colors.yellowAccent.withValues(alpha: 0.6);

    final landmarkPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.primaryNeon;

    final jointBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;

    for (final pose in poses) {
      // Dibujar líneas conectivas solo si ambos puntos tienen alta confianza
      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paint,
      ) {
        final joint1 = pose.landmarks[type1];
        final joint2 = pose.landmarks[type2];
        if (joint1 == null || joint2 == null) return;
        if (joint1.likelihood < 0.60 || joint2.likelihood < 0.60) return;

        canvas.drawLine(
          Offset(
            translateX(
                joint1.x, size, imageSize, rotation, cameraLensDirection),
            translateY(
                joint1.y, size, imageSize, rotation, cameraLensDirection),
          ),
          Offset(
            translateX(
                joint2.x, size, imageSize, rotation, cameraLensDirection),
            translateY(
                joint2.y, size, imageSize, rotation, cameraLensDirection),
          ),
          paint,
        );
      }

      // Brazos
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);

      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // Torso
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, basePaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, basePaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, basePaint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, basePaint);

      // Piernas
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, basePaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, basePaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, basePaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, basePaint);

      // Puntos articulares (Landmarks)
      pose.landmarks.forEach((_, landmark) {
        if (landmark.likelihood < 0.60) return;

        final offset = Offset(
          translateX(landmark.x, size, imageSize, rotation, cameraLensDirection),
          translateY(landmark.y, size, imageSize, rotation, cameraLensDirection),
        );

        canvas.drawCircle(offset, 4.0, landmarkPaint);
        canvas.drawCircle(offset, 4.0, jointBorderPaint);
      });
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.activeArm != activeArm ||
        oldDelegate.imageSize != imageSize;
  }
}
