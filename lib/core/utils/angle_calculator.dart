import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  /// Calcula el ángulo agudo/obtuso (0° a 180°) formado en el vértice [mid]
  /// por los puntos [first] y [last].
  static double calculateAngle(
    PoseLandmark first,
    PoseLandmark mid,
    PoseLandmark last,
  ) {
    final double radians = math.atan2(last.y - mid.y, last.x - mid.x) -
        math.atan2(first.y - mid.y, first.x - mid.x);

    double degrees = (radians * 180.0 / math.pi).abs();

    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    return degrees;
  }

  /// Calcula la distancia euclidiana 2D entre dos puntos clave
  static double distance(PoseLandmark p1, PoseLandmark p2) {
    return math.sqrt(
      math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2),
    );
  }

  /// Verifica si los tres puntos tienen una probabilidad de detección suficiente
  static bool areLandmarksReliable(
    PoseLandmark first,
    PoseLandmark mid,
    PoseLandmark last, {
    double minLikelihood = 0.65,
  }) {
    return first.likelihood >= minLikelihood &&
        mid.likelihood >= minLikelihood &&
        last.likelihood >= minLikelihood;
  }
}
