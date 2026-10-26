import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../../domain/repositories/i_pose_detector_repository.dart';
import '../../domain/usecases/process_pose_usecase.dart';
import 'push_up_state.dart';

class PushUpCubit extends Cubit<PushUpState> {
  final IPoseDetectorRepository _repository;
  final ProcessPoseUseCase _useCase;
  bool _isBusy = false;

  PushUpCubit({
    required IPoseDetectorRepository repository,
    ProcessPoseUseCase? useCase,
  })  : _repository = repository,
        _useCase = useCase ?? ProcessPoseUseCase(),
        super(PushUpState.initial());

  Future<void> processFrame(
    InputImage inputImage,
    CameraLensDirection lensDirection,
  ) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final poses = await _repository.processImage(inputImage);

      final updatedMetrics = _useCase.execute(
        poses: poses,
        currentMetrics: state.metrics,
      );

      emit(state.copyWith(
        metrics: updatedMetrics,
        poses: poses,
        imageSize: inputImage.metadata?.size,
        rotation: inputImage.metadata?.rotation,
        cameraLensDirection: lensDirection,
        isProcessing: false,
      ));
    } catch (_) {
      // Ignorar caídas aisladas de frames
    } finally {
      _isBusy = false;
    }
  }

  void resetCounter() {
    _useCase.reset();
    emit(state.copyWith(
      metrics: state.metrics.copyWith(
        repetitions: 0,
        currentAngle: 180.0,
        feedbackMessage: 'Contador reiniciado. ¡A entrenar!',
      ),
    ));
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}
