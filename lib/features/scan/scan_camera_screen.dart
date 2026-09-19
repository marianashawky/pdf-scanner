import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import 'crop_adjust_screen.dart';

class ScanCameraScreen extends ConsumerStatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  ConsumerState<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends ConsumerState<ScanCameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  var _ready = false;
  var _busy = false;
  var _flash = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _open();
    }
  }

  Future<void> _open() async {
    final granted = await ref.read(permissionServiceProvider).ensureCamera();
    if (!granted) {
      setState(() => _error = 'Camera access is needed to scan documents.');
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera is available on this device.');
        return;
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller?.dispose();
      setState(() {
        _controller = controller;
        _ready = true;
        _error = null;
      });
    } catch (error) {
      setState(() => _error = 'Could not start the camera. You can still import from the gallery.');
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      await _openCrop(file.path);
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _gallery() async {
    final allowed = await ref.read(permissionServiceProvider).ensurePhotos();
    if (!allowed && mounted) {
      showStudioError(context, 'Photo access is needed to import a page.');
      return;
    }
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (file == null || !mounted) return;
    await _openCrop(file.path);
  }

  Future<void> _openCrop(String path) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CropAdjustScreen(imagePath: path)),
    );
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    _flash = !_flash;
    await controller.setFlashMode(_flash ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: _ready && _controller != null
                ? CameraPreview(_controller!)
                : ColoredBox(
                    color: const Color(0xFF10161C),
                    child: Center(
                      child: _error == null
                          ? const CircularProgressIndicator(color: AppColors.primary)
                          : Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.manrope(color: Colors.white70),
                              ),
                            ),
                    ),
                  ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        background: Colors.black54,
                        foreground: Colors.white,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      CircleIconButton(
                        icon: _flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        background: Colors.black54,
                        foreground: Colors.white,
                        onTap: _toggleFlash,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: AspectRatio(
                    aspectRatio: 0.72,
                    child: CustomPaint(painter: _ViewfinderPainter()),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Position document inside the frame',
                    style: GoogleFonts.manrope(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundAction(icon: Icons.image_outlined, onTap: _gallery),
                      GestureDetector(
                        onTap: _capture,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: AppColors.primaryGlow, blurRadius: 24, offset: Offset(0, 8)),
                            ],
                            border: Border.all(color: Colors.white24, width: 6),
                          ),
                        ),
                      ),
                      _RoundAction(
                        icon: session.autoEnhance ? Icons.bolt_rounded : Icons.bolt_outlined,
                        onTap: () => ref.read(scanSessionProvider.notifier).toggleEnhance(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Capturing…'),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CircleIconButton(
      icon: icon,
      size: 52,
      background: const Color(0x3311161C),
      foreground: Colors.white,
      onTap: onTap,
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const arm = 26.0;
    final rect = Offset.zero & size;
    final points = [
      [rect.topLeft, Offset(arm, 0), Offset(0, arm)],
      [rect.topRight, Offset(-arm, 0), Offset(0, arm)],
      [rect.bottomRight, Offset(-arm, 0), Offset(0, -arm)],
      [rect.bottomLeft, Offset(arm, 0), Offset(0, -arm)],
    ];
    for (final corner in points) {
      final origin = corner[0];
      canvas.drawLine(origin, origin + corner[1], paint);
      canvas.drawLine(origin, origin + corner[2], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
