import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:test_1/domain/entities/exercise_metrics.dart';
import 'package:test_1/domain/entities/exercise_stage.dart';
import 'package:test_1/domain/usecases/process_pose_usecase.dart';

void main() {
  group('ProcessPoseUseCase Tests', () {
    late ProcessPoseUseCase useCase;

    setUp(() {
      useCase = ProcessPoseUseCase();
    });

    Pose createRealisticHumanPose({
      required double elbowAngle,
      bool isRightArm = true,
      double likelihood = 0.9,
    }) {
      // Articulaciones a escala humana real (> 100px)
      // Vértice en codo (0, 0)
      // Hombro en (0, 100)
      final shoulder = PoseLandmark(
        type: isRightArm ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder,
        x: 0,
        y: 100,
        z: 0,
        likelihood: likelihood,
      );

      final elbow = PoseLandmark(
        type: isRightArm ? PoseLandmarkType.rightElbow : PoseLandmarkType.leftElbow,
        x: 0,
        y: 0,
        z: 0,
        likelihood: likelihood,
      );

      // Si ángulo = 180 => muñeca en (0, -100)
      // Si ángulo = 80  => muñeca en (98, 17)
      double wristX = 0;
      double wristY = -100;

      if (elbowAngle <= 85) {
        wristX = 98;
        wristY = 17; // ~80 grados
      } else if (elbowAngle >= 155) {
        wristX = 0;
        wristY = -100; // 180 grados
      }

      final wrist = PoseLandmark(
        type: isRightArm ? PoseLandmarkType.rightWrist : PoseLandmarkType.leftWrist,
        x: wristX,
        y: wristY,
        z: 0,
        likelihood: likelihood,
      );

      // Cadera para validar torso (> 70px)
      final hip = PoseLandmark(
        type: isRightArm ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip,
        x: 0,
        y: 220,
        z: 0,
        likelihood: likelihood,
      );

      final oppositeShoulder = PoseLandmark(
        type: isRightArm ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder,
        x: 40,
        y: 100,
        z: 0,
        likelihood: 0.7,
      );

      final Map<PoseLandmarkType, PoseLandmark> landmarks = {
        isRightArm ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder: shoulder,
        isRightArm ? PoseLandmarkType.rightElbow : PoseLandmarkType.leftElbow: elbow,
        isRightArm ? PoseLandmarkType.rightWrist : PoseLandmarkType.leftWrist: wrist,
        isRightArm ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip: hip,
        isRightArm ? PoseLandmarkType.leftShoulder : PoseLandmarkType.rightShoulder: oppositeShoulder,
      };

      return Pose(landmarks: landmarks);
    }

    test('Devuelve búsqueda de persona si lista de poses está vacía', () {
      final initial = ExerciseMetrics.initial();
      final result = useCase.execute(poses: [], currentMetrics: initial);

      expect(result.activeArm, DetectedArm.none);
      expect(result.feedbackMessage, contains('Buscando postura'));
    });

    test('Rechaza poses fantasmas microscópicas (como texturas en zapatos u objetos)', () {
      // Simular puntos detectados en un área diminuta de 20x20px sobre un objeto
      final Map<PoseLandmarkType, PoseLandmark> tinyFakeLandmarks = {
        PoseLandmarkType.rightShoulder: PoseLandmark(
          type: PoseLandmarkType.rightShoulder,
          x: 10,
          y: 10,
          z: 0,
          likelihood: 0.45,
        ),
        PoseLandmarkType.rightElbow: PoseLandmark(
          type: PoseLandmarkType.rightElbow,
          x: 15,
          y: 12,
          z: 0,
          likelihood: 0.40,
        ),
        PoseLandmarkType.rightWrist: PoseLandmark(
          type: PoseLandmarkType.rightWrist,
          x: 20,
          y: 15,
          z: 0,
          likelihood: 0.35,
        ),
      };

      final fakePose = Pose(landmarks: tinyFakeLandmarks);
      final metrics = useCase.execute(
        poses: [fakePose],
        currentMetrics: ExerciseMetrics.initial(),
      );

      expect(metrics.activeArm, DetectedArm.none);
      expect(metrics.repetitions, 0);
      expect(metrics.feedbackMessage, contains('Colócate en el encuadre'));
    });

    test('Ciclo completo de flexión: Extensión -> Descenso (sostenido) -> Extensión incrementa repetición a 1', () {
      var metrics = ExerciseMetrics.initial();
      int time = 1000;

      // Paso 1: Postura inicial extendida (180 grados)
      final poseExtended = createRealisticHumanPose(elbowAngle: 180);
      metrics = useCase.execute(
        poses: [poseExtended],
        currentMetrics: metrics,
        currentTimeMs: time,
      );
      expect(metrics.repetitions, 0);
      expect(metrics.activeArm, DetectedArm.right);

      // Paso 2: Descenso a flexión profunda (80 grados) - frames sostenidos
      final poseDown = createRealisticHumanPose(elbowAngle: 80);
      for (int i = 0; i < 6; i++) {
        time += 50;
        metrics = useCase.execute(
          poses: [poseDown],
          currentMetrics: metrics,
          currentTimeMs: time,
        );
      }
      expect(metrics.stage, ExerciseStage.down);
      expect(metrics.repetitions, 0);

      // Paso 3: Retorno a extensión completa (180 grados)
      time += 900; // Pasaron más de 800ms
      while (metrics.repetitions == 0) {
        time += 50;
        metrics = useCase.execute(
          poses: [poseExtended],
          currentMetrics: metrics,
          currentTimeMs: time,
        );
      }

      expect(metrics.repetitions, 1);
      expect(metrics.feedbackMessage, contains('Repetición #1 completada'));
    });

    test('Detecta automáticamente el brazo izquierdo si tiene mayor confianza', () {
      final leftPose = createRealisticHumanPose(elbowAngle: 180, isRightArm: false, likelihood: 0.95);
      final metrics = useCase.execute(
        poses: [leftPose],
        currentMetrics: ExerciseMetrics.initial(),
      );

      expect(metrics.activeArm, DetectedArm.left);
    });
  });
}
