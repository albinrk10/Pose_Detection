import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class MLKitPoseDataSource {
  final PoseDetector _detector;

  MLKitPoseDataSource({PoseDetectorOptions? options})
      : _detector = PoseDetector(
          options: options ??
              PoseDetectorOptions(
                model: PoseDetectionModel.accurate,
                mode: PoseDetectionMode.stream,
              ),
        );

  Future<List<Pose>> detect(InputImage inputImage) async {
    return await _detector.processImage(inputImage);
  }

  Future<void> close() async {
    await _detector.close();
  }
}
