import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../infrastructure/repositories/pose_detector_repository_impl.dart';
import '../cubit/push_up_cubit.dart';
import '../cubit/push_up_state.dart';
import '../widgets/camera_feed_widget.dart';
import '../widgets/modern_counter_overlay.dart';
import '../widgets/pose_painter.dart';

class PoseDetectorPage extends StatefulWidget {
  const PoseDetectorPage({super.key});

  @override
  State<PoseDetectorPage> createState() => _PoseDetectorPageState();
}

class _PoseDetectorPageState extends State<PoseDetectorPage> {
  final GlobalKey<CameraFeedWidgetState> _cameraKey = GlobalKey<CameraFeedWidgetState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PushUpCubit(
        repository: PoseDetectorRepositoryImpl(),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<PushUpCubit, PushUpState>(
          builder: (context, state) {
            final cubit = context.read<PushUpCubit>();

            return Stack(
              fit: StackFit.expand,
              children: [
                // Feed de la cámara
                CameraFeedWidget(
                  key: _cameraKey,
                  cubit: cubit,
                ),

                // Esqueleto visual dibujado sobre la cámara (CustomPaint)
                if (state.imageSize != null && state.rotation != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PosePainter(
                        poses: state.poses,
                        imageSize: state.imageSize!,
                        rotation: state.rotation!,
                        cameraLensDirection: state.cameraLensDirection,
                        activeArm: state.metrics.activeArm,
                      ),
                    ),
                  ),

                // Superposición moderna con métricas, contador y controles
                ModernCounterOverlay(
                  metrics: state.metrics,
                  onReset: cubit.resetCounter,
                  onBack: () => Navigator.of(context).pop(),
                  onSwitchCamera: () {
                    _cameraKey.currentState?.switchCamera();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
