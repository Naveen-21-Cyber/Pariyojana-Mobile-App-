import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/glass_snackbar.dart';
class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isReady = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }

  Future<void> _setupCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        await _initCamera(_cameras.first);
      }
    } catch (e) {
      debugPrint('Error finding cameras: $e');
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Play tactile shutter haptics
      await HapticFeedback.mediumImpact();
      
      final XFile rawImage = await _controller!.takePicture();
      
      // Save permanently to documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String extension = rawImage.path.split('.').last;
      final String permanentPath = '${directory.path}/idea_${const Uuid().v4()}.$extension';
      
      await File(rawImage.path).copy(permanentPath);
      
      // Play success click
      await HapticFeedback.vibrate();

      if (mounted) {
        Navigator.of(context).pop(permanentPath);
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        GlassSnackBar.show(
          context,
          'Failed to capture photo: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Centered 3:4 Camera Preview
          Center(
            child: _isReady && _controller != null
                ? AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRect(
                      child: CameraPreview(_controller!),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: VelvetColors.coralPeach),
                  ),
          ),

          // 2. Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),

          // 3. Viewfinder Controls Panel
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: VelvetColors.coralPeach, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Flash Toggle Button
                    IconButton(
                      icon: const Icon(
                        Icons.flash_auto_rounded,
                        color: VelvetColors.periwinkle,
                        size: 28,
                      ),
                      tooltip: 'Auto Flash',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                      },
                    ),

                    // Shutter Button
                    GestureDetector(
                      onTap: _capturePhoto,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VelvetColors.cream,
                          boxShadow: [
                            BoxShadow(
                              color: VelvetColors.coralPeach.withValues(alpha: 0.35),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: VelvetColors.coralPeach,
                            width: 3.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: VelvetColors.coralPeach,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Camera Switch (Front/Back)
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_android_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (_cameras.length > 1) {
                          final currentDesc = _controller?.description;
                          final nextCam = _cameras.firstWhere(
                            (c) => c.lensDirection != currentDesc?.lensDirection,
                            orElse: () => _cameras.first,
                          );
                          _initCamera(nextCam);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
