import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

late List<CameraDescription> cameras;

class YoloPage extends StatefulWidget {
  const YoloPage({super.key});

  @override
  State<YoloPage> createState() => _YoloPageState();
}

class _YoloPageState extends State<YoloPage>
    with SingleTickerProviderStateMixin {
  CameraController? controller;
  late FlutterVision vision;
  late FlutterTts tts;

  bool isLoaded = false;
  bool isRealtime = false;
  bool isDetecting = false;
  bool voiceEnabled = true;
  bool _isDisposing = false;
  bool isClosing = false;

  List<Map<String, dynamic>> yoloResults = [];

  String lastSpoken = "";
  String latestDetected = "";
  int lastTime = 0;

  double speechRate = 0.4;
  double speakCooldown = 3000;
  double confThreshold = 0.75;

  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    initYolo();
  }

  Future<void> initYolo() async {
    vision = FlutterVision();
    tts = FlutterTts();

    await tts.setLanguage("id-ID");
    await tts.setSpeechRate(speechRate);

    if (cameras.isEmpty) return;

    controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();

    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/uang.tflite',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: false,
    );

    setState(() {
      isLoaded = true;
    });

    startRealtime();
  }

  void startRealtime() {
    if (isRealtime || controller == null) return;

    isRealtime = true;

    controller!.startImageStream((image) async {
      if (!mounted) return;
      if (isClosing) return;

      if (!isRealtime || isDetecting) return;

      isDetecting = true;

      try {
        final result = await vision.yoloOnFrame(
          bytesList: image.planes.map((e) => e.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.3,
          confThreshold: confThreshold,
          classThreshold: confThreshold,
        );

        if (!mounted || isClosing) {
          isDetecting = false;
          return;
        }

        setState(() {
          yoloResults = result;

          if (result.isNotEmpty) {
            latestDetected = result.first['tag'];
          }
        });

        if (result.isNotEmpty && voiceEnabled) {
          await speakResult(result.first['tag']);
        }
      } catch (e) {
        debugPrint("YOLO ERROR: $e");
      }

      isDetecting = false;
    });

    setState(() {});
  }

  Future<void> stopRealtime() async {
    isRealtime = false;
    await controller?.stopImageStream();
    setState(() {});
  }

  Future<void> speakResult(String text) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (text != lastSpoken || now - lastTime > speakCooldown.toInt()) {
      await tts.stop();
      await tts.setSpeechRate(speechRate);
      await tts.speak(text);

      lastSpoken = text;
      lastTime = now;
    }
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: .2)),
          ),
          child: child,
        ),
      ),
    );
  }

  List<Widget> displayBoxes() {
    if (yoloResults.isEmpty || controller == null) return [];

    final screen = MediaQuery.of(context).size;

    // ukuran image kamera yang dipakai model
    final previewH = controller!.value.previewSize!.height;
    final previewW = controller!.value.previewSize!.width;

    // camera portrait biasanya kebalik
    final scaleX = screen.width / previewH;
    final scaleY = screen.height / previewW;

    return yoloResults.map((r) {
      final box = r["box"];

      double x = box[0] * scaleX;
      double y = box[1] * scaleY;
      double w = box[2] * scaleX;
      double h = box[3] * scaleY;

      return Positioned(
        left: x,
        top: y,
        width: w,
        height: h,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 3),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                r["tag"],
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget buildTopHud() {
    return Positioned(
      top: 55,
      left: 18,
      right: 18,
      child: Column(
        children: [
          glassCard(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, _) {
                    return Container(
                      width: 14 + pulseController.value * 5,
                      height: 14 + pulseController.value * 5,
                      decoration: BoxDecoration(
                        color: isRealtime ? Colors.greenAccent : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    isRealtime
                        ? 'Deteksi uang realtime aktif'
                        : 'Deteksi berhenti',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Chip(
                  backgroundColor: Colors.black12,
                  label: Text(
                    '${yoloResults.length} objek',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget buildControlPanel() {
    return Positioned(
      bottom: 60,
      left: 16,
      right: 16,
      child: glassCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _metric(
                    'Voice',
                    voiceEnabled ? 'ON' : 'OFF',
                    Icons.volume_up,
                  ),
                ),
                Expanded(
                  child: _metric(
                    'Speed',
                    speechRate.toStringAsFixed(1),
                    Icons.speed,
                  ),
                ),
                Expanded(
                  child: _metric(
                    'Conf',
                    confThreshold.toStringAsFixed(1),
                    Icons.analytics,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _sliderTitle('Kecepatan suara', Icons.record_voice_over),

            Slider(
              value: speechRate,
              min: 0.2,
              max: 0.8,
              onChanged: (v) async {
                setState(() => speechRate = v);
                await tts.setSpeechRate(v);
              },
            ),

            _sliderTitle('Interval pengulangan suara', Icons.timer),

            Slider(
              value: speakCooldown,
              min: 1000,
              max: 5000,
              divisions: 8,
              onChanged: (v) {
                setState(() => speakCooldown = v);
              },
            ),

            _sliderTitle('Sensitivity detection', Icons.tune),

            Slider(
              value: confThreshold,
              min: 0.2,
              max: 0.9,
              onChanged: (v) {
                setState(() => confThreshold = v);
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        voiceEnabled = !voiceEnabled;
                      });
                    },
                    icon: Icon(
                      voiceEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    label: const Text(
                      'Voice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRealtime ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        if (isRealtime) {
                          stopRealtime();
                        } else {
                          startRealtime();
                        }
                      },
                      icon: Icon(
                        isRealtime ? Icons.stop_circle : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      label: Text(
                        isRealtime ? 'Stop Scan' : 'Start Scan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 8)),
      ],
    );
  }

  Widget _sliderTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    cleanupCamera();

    pulseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await safeCloseCamera();

        if (!mounted) return;

        Get.back();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: CameraPreview(controller!)),

            ...displayBoxes(),

            buildTopHud(),

            buildControlPanel(),
          ],
        ),
      ),
    );
  }

  Future<void> safeCloseCamera() async {
    if (isClosing) return;

    isClosing = true;

    try {
      // stop realtime dulu
      isRealtime = false;

      // tunggu inference selesai
      while (isDetecting) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // baru stop stream
      if (controller?.value.isStreamingImages == true) {
        await controller?.stopImageStream();
      }

      await Future.delayed(const Duration(milliseconds: 300));

      // dispose camera
      await controller?.dispose();

      // tutup model
      await vision.closeYoloModel();

      // stop TTS
      await tts.stop();
    } catch (e) {
      debugPrint("SAFE CLOSE ERROR: $e");
    }
  }

  Future<void> cleanupCamera() async {
    if (_isDisposing) return;

    _isDisposing = true;

    try {
      isRealtime = false;
      isDetecting = false;

      // stop image stream dulu
      if (controller?.value.isStreamingImages == true) {
        await controller?.stopImageStream();
      }

      // kasih delay kecil biar callback terakhir selesai
      await Future.delayed(const Duration(milliseconds: 200));

      // dispose camera
      await controller?.dispose();

      // tutup yolo
      await vision.closeYoloModel();

      // stop suara
      await tts.stop();
    } catch (e) {
      debugPrint("Cleanup error: $e");
    }
  }
}
