import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';

late List<CameraDescription> cameras;

class YoloPage extends StatefulWidget {
  const YoloPage({super.key});

  @override
  State<YoloPage> createState() => _YoloPageState();
}

class _YoloPageState extends State<YoloPage> {
  CameraController? controller;
  late FlutterVision vision;
  late FlutterTts tts;

  bool isLoaded = false;
  bool isRealtime = false;
  bool isDetecting = false;

  List<Map<String, dynamic>> yoloResults = [];

  String lastSpoken = "";
  int lastTime = 0;

  @override
  void initState() {
    super.initState();
    initYolo();
  }

  Future<void> initYolo() async {
    vision = FlutterVision();
    tts = FlutterTts();

    await tts.setLanguage("id-ID");
    await tts.setSpeechRate(0.4);

    if (cameras.isEmpty) return;

    controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
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
      if (!isRealtime || isDetecting) return;

      isDetecting = true;

      try {
        final result = await vision.yoloOnFrame(
          bytesList: image.planes.map((e) => e.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.3,
          confThreshold: 0.4,
          classThreshold: 0.4,
        );

        if (mounted) {
          setState(() {
            yoloResults = result;
          });
        }

        if (result.isNotEmpty) {
          speakResult(result.first["tag"]);
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      await Future.delayed(const Duration(milliseconds: 150));

      isDetecting = false;
    });
  }

  Future<void> stopRealtime() async {
    isRealtime = false;
    await controller?.stopImageStream();
  }

  Future<void> speakResult(String text) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (text != lastSpoken || now - lastTime > 2500) {
      await tts.stop();
      await tts.speak(text);

      lastSpoken = text;
      lastTime = now;
    }
  }

  List<Widget> displayBoxes() {
    if (yoloResults.isEmpty) return [];

    return yoloResults.map((r) {
      final box = r["box"];

      return Positioned(
        left: box[0],
        top: box[1],
        width: box[2],
        height: box[3],
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.greenAccent,
              child: Text(
                r["tag"],
                style: const TextStyle(
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

  @override
  void dispose() {
    controller?.dispose();
    vision.closeYoloModel();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(controller!),

          ...displayBoxes(),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Deteksi Uang Realtime",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: isRealtime ? Colors.red : Colors.green,
                onPressed: () {
                  if (isRealtime) {
                    stopRealtime();
                  } else {
                    startRealtime();
                  }

                  setState(() {});
                },
                child: Icon(isRealtime ? Icons.stop : Icons.play_arrow),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
