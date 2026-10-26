import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class IPoseDetectorRepository {
  Future<List<Pose>> processImage(InputImage inputImage);
  Future<void> dispose();
}
