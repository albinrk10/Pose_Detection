import 'exercise_stage.dart';

class ExerciseMetrics {
  final int repetitions;
  final double currentAngle;
  final ExerciseStage stage;
  final DetectedArm activeArm;
  final String feedbackMessage;

  const ExerciseMetrics({
    required this.repetitions,
    required this.currentAngle,
    required this.stage,
    required this.activeArm,
    required this.feedbackMessage,
  });

  factory ExerciseMetrics.initial() {
    return const ExerciseMetrics(
      repetitions: 0,
      currentAngle: 180.0,
      stage: ExerciseStage.neutral,
      activeArm: DetectedArm.none,
      feedbackMessage: 'Colócate de perfil para iniciar',
    );
  }

  ExerciseMetrics copyWith({
    int? repetitions,
    double? currentAngle,
    ExerciseStage? stage,
    DetectedArm? activeArm,
    String? feedbackMessage,
  }) {
    return ExerciseMetrics(
      repetitions: repetitions ?? this.repetitions,
      currentAngle: currentAngle ?? this.currentAngle,
      stage: stage ?? this.stage,
      activeArm: activeArm ?? this.activeArm,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
    );
  }
}
