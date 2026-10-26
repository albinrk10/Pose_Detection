import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import '../cubit/push_up_cubit.dart';

class CameraFeedWidget extends StatefulWidget {
  final PushUpCubit cubit;
  final CameraLensDirection initialDirection;
  final void Function(CameraController controller)? onControllerCreated;

  const CameraFeedWidget({
    super.key,
    required this.cubit,
    this.initialDirection = CameraLensDirection.back,
    this.onControllerCreated,
  });

  @override
  State<CameraFeedWidget> createState() => CameraFeedWidgetState();
}

class CameraFeedWidgetState extends State<CameraFeedWidget> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _isSwitching = false;

  CameraLensDirection get currentLensDirection =>
      _cameraIndex != -1 ? _cameras[_cameraIndex].lensDirection : widget.initialDirection;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }

    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
        break;
      }
    }

    if (_cameraIndex == -1 && _cameras.isNotEmpty) {
      _cameraIndex = 0;
    }

    if (_cameraIndex != -1) {
      await _startCamera();
    }
  }

  Future<void> _startCamera() async {
    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _controller?.initialize();

    if (!mounted) return;

    if (widget.onControllerCreated != null && _controller != null) {
      widget.onControllerCreated!(_controller!);
    }

    await _controller?.startImageStream(_processImageStream);
    setState(() {});
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || _isSwitching) return;
    setState(() => _isSwitching = true);

    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera();

    if (mounted) {
      setState(() => _isSwitching = false);
    }
  }

  void _processImageStream(CameraImage image) {
    final inputImage = _buildInputImage(image);
    if (inputImage == null) return;
    widget.cubit.processFrame(inputImage, currentLensDirection);
  }

  InputImage? _buildInputImage(CameraImage image) {
    if (_controller == null || _cameraIndex == -1) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      const orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

      var compensation = orientations[_controller!.value.deviceOrientation];
      if (compensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        compensation = (sensorOrientation + compensation) % 360;
      } else {
        compensation = (sensorOrientation - compensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return CameraPreview(_controller!);
  }
}
