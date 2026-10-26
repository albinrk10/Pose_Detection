import 'dart:math' as math;
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../core/utils/angle_calculator.dart';
import '../entities/exercise_metrics.dart';
import '../entities/exercise_stage.dart';

class ProcessPoseUseCase {
  // Umbrales biomecánicos en grados
  static const double extensionThreshold = 155.0; // Brazo extendido (arriba)
  static const double flexionThreshold = 85.0;    // Pecho abajo (flexión completada)
  static const double completionThreshold = 150.0; // Retorno a extensión

  // Filtros de calidad y proporciones humanas mínimas (Anti-fantasmas)
  static const double minLandmarkLikelihood = 0.65; // Confianza mínima del punto
  static const double minTorsoDistance = 70.0;     // Distancia mínima hombro-cadera en px
  static const double minArmSegmentLength = 35.0;  // Distancia mínima hombro-codo y codo-muñeca en px
  static const double minPoseDiagonal = 120.0;     // Bounding box diagonal mínima del cuerpo

  // Filtro temporal para evitar conteos fantasmas por ruido de cámara
  static const int minDownFrames = 2; // Frames consecutivos en 'down' para validar descenso
  static const int minRepIntervalMs = 800; // Mínimo 800ms entre flexiones humanas reales

  // Estado interno para suavizado y persistencia temporal
  double? _smoothedAngle;
  int _consecutiveDownFrames = 0;
  int _lastRepTimeMs = 0;

  /// Reinicia el filtro de suavizado y estados temporales
  void reset() {
    _smoothedAngle = null;
    _consecutiveDownFrames = 0;
    _lastRepTimeMs = 0;
  }

  /// Valida que la pose corresponda a un cuerpo humano real y no a un objeto pequeño o textura
  bool isRealHumanPose(Pose pose) {
    // 1. Verificar presencia de torso (Hombro + Cadera con alta confianza)
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];

    bool hasTorso = false;
    if (rightShoulder != null && rightHip != null &&
        rightShoulder.likelihood >= minLandmarkLikelihood &&
        rightHip.likelihood >= minLandmarkLikelihood) {
      if (AngleCalculator.distance(rightShoulder, rightHip) >= minTorsoDistance) {
        hasTorso = true;
      }
    }

    if (!hasTorso && leftShoulder != null && leftHip != null &&
        leftShoulder.likelihood >= minLandmarkLikelihood &&
        leftHip.likelihood >= minLandmarkLikelihood) {
      if (AngleCalculator.distance(leftShoulder, leftHip) >= minTorsoDistance) {
        hasTorso = true;
      }
    }

    if (!hasTorso) return false;

    // 2. Verificar tamaño de la caja delimitadora (Bounding Box de landmarks confiables)
    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;
    int confidentPoints = 0;

    for (final landmark in pose.landmarks.values) {
      if (landmark.likelihood >= minLandmarkLikelihood) {
        confidentPoints++;
        if (landmark.x < minX) minX = landmark.x;
        if (landmark.x > maxX) maxX = landmark.x;
        if (landmark.y < minY) minY = landmark.y;
        if (landmark.y > maxY) maxY = landmark.y;
      }
    }

    // Un cuerpo humano real en pantalla tiene varios puntos articulados y un tamaño visible razonable
    if (confidentPoints < 5) return false;

    final width = maxX - minX;
    final height = maxY - minY;
    final diagonal = math.sqrt(width * width + height * height);

    return diagonal >= minPoseDiagonal;
  }

  /// Procesa una lista de poses detectadas y actualiza las métricas del ejercicio
  ExerciseMetrics execute({
    required List<Pose> poses,
    required ExerciseMetrics currentMetrics,
    int? currentTimeMs,
  }) {
    if (poses.isEmpty) {
      _smoothedAngle = null;
      _consecutiveDownFrames = 0;
      return currentMetrics.copyWith(
        activeArm: DetectedArm.none,
        feedbackMessage: 'Buscando postura corporal...',
      );
    }

    final pose = poses.first;

    // FILTRO 1: Validar que sea un cuerpo humano de tamaño y proporciones válidas
    if (!isRealHumanPose(pose)) {
      _smoothedAngle = null;
      _consecutiveDownFrames = 0;
      return currentMetrics.copyWith(
        activeArm: DetectedArm.none,
        feedbackMessage: 'Colócate en el encuadre para iniciar',
      );
    }

    // Articulaciones del lado derecho
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    // Articulaciones del lado izquierdo
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

    // Evaluar confianza y longitud mínima de segmentos de brazo
    final rightReliable = rightShoulder != null &&
        rightElbow != null &&
        rightWrist != null &&
        AngleCalculator.areLandmarksReliable(
          rightShoulder,
          rightElbow,
          rightWrist,
          minLikelihood: minLandmarkLikelihood,
        ) &&
        AngleCalculator.distance(rightShoulder, rightElbow) >= minArmSegmentLength &&
        AngleCalculator.distance(rightElbow, rightWrist) >= minArmSegmentLength;

    final leftReliable = leftShoulder != null &&
        leftElbow != null &&
        leftWrist != null &&
        AngleCalculator.areLandmarksReliable(
          leftShoulder,
          leftElbow,
          leftWrist,
          minLikelihood: minLandmarkLikelihood,
        ) &&
        AngleCalculator.distance(leftShoulder, leftElbow) >= minArmSegmentLength &&
        AngleCalculator.distance(leftElbow, leftWrist) >= minArmSegmentLength;

    if (!rightReliable && !leftReliable) {
      return currentMetrics.copyWith(
        activeArm: DetectedArm.none,
        feedbackMessage: 'Ponte de perfil para detectar el codo',
      );
    }

    // Elegir el brazo con mayor confianza promedio
    final double rightScore = rightReliable
        ? (rightShoulder.likelihood +
                rightElbow.likelihood +
                rightWrist.likelihood) /
            3.0
        : 0.0;

    final double leftScore = leftReliable
        ? (leftShoulder.likelihood +
                leftElbow.likelihood +
                leftWrist.likelihood) /
            3.0
        : 0.0;

    DetectedArm activeArm;
    double rawAngle;

    if (rightScore >= leftScore && rightReliable) {
      activeArm = DetectedArm.right;
      rawAngle = AngleCalculator.calculateAngle(
        rightShoulder,
        rightElbow,
        rightWrist,
      );
    } else {
      activeArm = DetectedArm.left;
      rawAngle = AngleCalculator.calculateAngle(
        leftShoulder!,
        leftElbow!,
        leftWrist!,
      );
    }

    // FILTRO 2: Suavizado Exponencial del Ángulo (EMA) para eliminar ruido y micro-saltos
    if (_smoothedAngle == null) {
      _smoothedAngle = rawAngle;
    } else {
      _smoothedAngle = (_smoothedAngle! * 0.35) + (rawAngle * 0.65);
    }
    final currentAngle = _smoothedAngle!;

    // FILTRO 3: Máquina de estados con confirmación de descenso y debounce de tiempo
    final now = currentTimeMs ?? DateTime.now().millisecondsSinceEpoch;
    ExerciseStage newStage = currentMetrics.stage;
    int newReps = currentMetrics.repetitions;
    String feedback = currentMetrics.feedbackMessage;

    switch (currentMetrics.stage) {
      case ExerciseStage.neutral:
        if (currentAngle >= extensionThreshold) {
          _consecutiveDownFrames = 0;
          feedback = '¡Posición inicial lista! Baja el pecho';
        } else if (currentAngle <= flexionThreshold) {
          _consecutiveDownFrames++;
          // Solo entrar en 'down' si permanece abajo al menos 2 frames consecutivos
          if (_consecutiveDownFrames >= minDownFrames) {
            newStage = ExerciseStage.down;
            feedback = '¡Flexión iniciada! Ahora empuja hacia arriba';
          }
        } else {
          feedback = 'Extiende completamente los brazos';
        }
        break;

      case ExerciseStage.down:
        if (currentAngle >= completionThreshold) {
          // Validar que haya pasado un tiempo humano razonable desde la última flexión
          if (now - _lastRepTimeMs >= minRepIntervalMs) {
            newReps += 1;
            _lastRepTimeMs = now;
            newStage = ExerciseStage.neutral;
            _consecutiveDownFrames = 0;
            feedback = '¡Excelente! Repetición #$newReps completada';
          } else {
            newStage = ExerciseStage.neutral;
            _consecutiveDownFrames = 0;
          }
        } else if (currentAngle <= flexionThreshold) {
          feedback = '¡Buen descenso! Empuja hacia arriba';
        } else {
          feedback = 'Continúa subiendo hasta extender los brazos';
        }
        break;

      case ExerciseStage.up:
        newStage = ExerciseStage.neutral;
        _consecutiveDownFrames = 0;
        feedback = '¡Listo para la siguiente flexión!';
        break;
    }

    return currentMetrics.copyWith(
      repetitions: newReps,
      currentAngle: currentAngle,
      stage: newStage,
      activeArm: activeArm,
      feedbackMessage: feedback,
    );
  }
}
