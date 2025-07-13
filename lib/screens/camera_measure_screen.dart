import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/heart_rate_chart.dart';

class CameraMeasureScreen extends StatefulWidget {
  const CameraMeasureScreen({super.key});

  @override
  State<CameraMeasureScreen> createState() => _CameraMeasureScreenState();
}

class _CameraMeasureScreenState extends State<CameraMeasureScreen> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isFingerDetected = false;
  bool _isMeasuring = false;
  bool _fingerLifted = false;
  int _timer = 30;
  Timer? _measurementTimer;
  Timer? _frameCheckTimer;
  Timer? _fingerLiftedTimer;
  List<FlSpot> _dataPoints = [];
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.off);

    setState(() => _isCameraInitialized = true);

    _startFrameCheck();
  }

  void _startFrameCheck() {
    _frameCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) async {
      if (!_controller.value.isStreamingImages) {
        await _controller.startImageStream(_processCameraImage);
      }
    });
  }

  void _processCameraImage(CameraImage image) {
    final stats = _calculateColorStats(image);
    final red = stats['red']!;
    final green = stats['green']!;
    final blue = stats['blue']!;

    final isFinger = red > 120 && green < 80 && blue < 80;

    if (isFinger) {
      if (!_isFingerDetected) {
        setState(() {
          _isFingerDetected = true;
          _fingerLifted = false;
        });
        _fingerLiftedTimer?.cancel();
      }

      if (!_isMeasuring) {
        _startMeasurement();
      }

      _collectDataPoint(red.toDouble());
    } else {
      if (_isFingerDetected) {
        _fingerLiftedTimer ??= Timer(const Duration(seconds: 3), () {
          setState(() {
            _fingerLifted = true;
            _isFingerDetected = false;
            _stopMeasurement();
          });
        });
      }
    }
  }

  Map<String, int> _calculateColorStats(CameraImage image) {
    final redPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    int red = 0;
    int green = 0;
    int blue = 0;
    int count = 0;

    for (int i = 0; i < redPlane.bytes.length; i += 100) {
      final y = redPlane.bytes[i].toDouble();
      final u = uPlane.bytes[i].toDouble() - 128.0;
      final v = vPlane.bytes[i].toDouble() - 128.0;

      final r = (y + 1.403 * v).clamp(0, 255).toInt();
      final g = (y - 0.344 * u - 0.714 * v).clamp(0, 255).toInt();
      final b = (y + 1.770 * u).clamp(0, 255).toInt();

      red += r;
      green += g;
      blue += b;
      count++;
    }

    return {
      'red': (red / count).round(),
      'green': (green / count).round(),
      'blue': (blue / count).round(),
    };
  }

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
      _timer = 30;
      _elapsedSeconds = 0;
      _dataPoints = [];
    });

    _measurementTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (_timer <= 0) {
        _stopMeasurement();
        HapticFeedback.heavyImpact();
      } else {
        setState(() => _timer--);
        _elapsedSeconds++;
        HapticFeedback.selectionClick();
      }
    });
  }

  void _stopMeasurement() {
    _measurementTimer?.cancel();
    _fingerLiftedTimer?.cancel();
    setState(() => _isMeasuring = false);
  }

  void _collectDataPoint(double value) {
    setState(() {
      _dataPoints.add(FlSpot(_elapsedSeconds, value));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _measurementTimer?.cancel();
    _frameCheckTimer?.cancel();
    _fingerLiftedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_controller),
                Container(color: Colors.black.withOpacity(0.3)),
                if (_isFingerDetected)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        'Finger Detected',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ),
                  )
                else if (_fingerLifted)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        'Finger Lifted',
                        style: TextStyle(fontSize: 20, color: Colors.redAccent),
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        'No Finger Detected',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ),
                  ),
                if (_isMeasuring)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Measuring: $_timer s',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: HeartRateChart(data: _dataPoints),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
