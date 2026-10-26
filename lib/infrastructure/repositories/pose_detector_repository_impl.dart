import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/repositories/i_pose_detector_repository.dart';
import '../datasources/mlkit_pose_datasource.dart';

class PoseDetectorRepositoryImpl implements IPoseDetectorRepository {
  final MLKitPoseDataSource _dataSource;

  PoseDetectorRepositoryImpl({MLKitPoseDataSource? dataSource})
      : _dataSource = dataSource ?? MLKitPoseDataSource();

  @override
  Future<List<Pose>> processImage(InputImage inputImage) async {
    return await _dataSource.detect(inputImage);
  }

  @override
  Future<void> dispose() async {
    await _dataSource.close();
  }
}
