import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/entities/exercise_metrics.dart';

class PushUpState {
  final ExerciseMetrics metrics;
  final List<Pose> poses;
  final Size? imageSize;
  final InputImageRotation? rotation;
  final CameraLensDirection cameraLensDirection;
  final bool isProcessing;

  const PushUpState({
    required this.metrics,
    required this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection = CameraLensDirection.back,
    this.isProcessing = false,
  });

  factory PushUpState.initial() {
    return PushUpState(
      metrics: ExerciseMetrics.initial(),
      poses: const [],
      cameraLensDirection: CameraLensDirection.back,
      isProcessing: false,
    );
  }

  PushUpState copyWith({
    ExerciseMetrics? metrics,
    List<Pose>? poses,
    Size? imageSize,
    InputImageRotation? rotation,
    CameraLensDirection? cameraLensDirection,
    bool? isProcessing,
  }) {
    return PushUpState(
      metrics: metrics ?? this.metrics,
      poses: poses ?? this.poses,
      imageSize: imageSize ?? this.imageSize,
      rotation: rotation ?? this.rotation,
      cameraLensDirection: cameraLensDirection ?? this.cameraLensDirection,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
