import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_1/core/utils/angle_calculator.dart';

void main() {
  group('AngleCalculator Tests', () {
    test('Calcula correctamente ángulo recto de 90 grados', () {
      // Vértice en (0, 0)
      // Primer punto hacia arriba (0, 10)
      // Último punto hacia la derecha (10, 0)
      final p1 = PoseLandmark(
        type: PoseLandmarkType.rightShoulder,
        x: 0,
        y: 10,
        z: 0,
        likelihood: 0.9,
      );
      final pMid = PoseLandmark(
        type: PoseLandmarkType.rightElbow,
        x: 0,
        y: 0,
        z: 0,
        likelihood: 0.9,
      );
      final p2 = PoseLandmark(
        type: PoseLandmarkType.rightWrist,
        x: 10,
        y: 0,
        z: 0,
        likelihood: 0.9,
      );

      final angle = AngleCalculator.calculateAngle(p1, pMid, p2);
      expect(angle, closeTo(90.0, 0.01));
    });

    test('Calcula correctamente ángulo llano de 180 grados (brazo extendido)', () {
      final p1 = PoseLandmark(
        type: PoseLandmarkType.rightShoulder,
        x: -10,
        y: 0,
        z: 0,
        likelihood: 0.9,
      );
      final pMid = PoseLandmark(
        type: PoseLandmarkType.rightElbow,
        x: 0,
        y: 0,
        z: 0,
        likelihood: 0.9,
      );
      final p2 = PoseLandmark(
        type: PoseLandmarkType.rightWrist,
        x: 10,
        y: 0,
        z: 0,
        likelihood: 0.9,
      );

      final angle = AngleCalculator.calculateAngle(p1, pMid, p2);
      expect(angle, closeTo(180.0, 0.01));
    });

    test('areLandmarksReliable valida el umbral de likelihood', () {
      final p1 = PoseLandmark(
        type: PoseLandmarkType.rightShoulder,
        x: 0,
        y: 0,
        z: 0,
        likelihood: 0.8,
      );
      final pMid = PoseLandmark(
        type: PoseLandmarkType.rightElbow,
        x: 0,
        y: 0,
        z: 0,
        likelihood: 0.7,
      );
      final pLow = PoseLandmark(
        type: PoseLandmarkType.rightWrist,
        x: 0,
        y: 0,
        z: 0,
        likelihood: 0.2, // Muy bajo
      );

      expect(AngleCalculator.areLandmarksReliable(p1, pMid, pLow, minLikelihood: 0.5), isFalse);
    });
  });
}
