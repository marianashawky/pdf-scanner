import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import 'scan_result_screen.dart';

class CropAdjustScreen extends ConsumerStatefulWidget {
  const CropAdjustScreen({
    super.key,
    required this.imagePath,
    this.replaceCurrent = false,
  });

  final String imagePath;
  final bool replaceCurrent;

  @override
  ConsumerState<CropAdjustScreen> createState() => _CropAdjustScreenState();
}

class _CropAdjustScreenState extends ConsumerState<CropAdjustScreen> {
  late QuadCorners _corners = QuadCorners.full;
  var _rotation = 0;
  var _busy = false;
  var _detected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _detect());
  }

  Future<void> _detect() async {
    try {
      final image = await ref.read(imageProcessingProvider).decode(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _corners = ref.read(imageProcessingProvider).detectDocument(image);
        _detected = true;
      });
    } catch (_) {
      setState(() => _detected = true);
    }
  }

  Future<void> _preview() async {
    setState(() => _busy = true);
    try {
      final settings = ref.read(settingsProvider);
      final enhance = ref.read(scanSessionProvider).autoEnhance;
      final bytes = await ref.read(imageProcessingProvider).processPage(
            sourcePath: widget.imagePath,
            corners: _corners,
            rotation: _rotation,
            filter: enhance ? ScanFilter.color : ScanFilter.original,
            quality: settings.quality,
            enhance: enhance,
          );
      final cache = await ref.read(documentStoreProvider).cacheDir();
      final processed = await ref.read(imageProcessingProvider).writeProcessed(bytes: bytes, directory: cache);
      final page = ScanPage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sourcePath: widget.imagePath,
        processedPath: processed,
        rotation: _rotation,
        filter: enhance ? ScanFilter.color : ScanFilter.original,
        corners: _corners,
      );
      if (widget.replaceCurrent) {
        ref.read(scanSessionProvider.notifier).updateCurrent(page);
      } else {
        ref.read(scanSessionProvider.notifier).addPage(page);
      }
      if (!mounted) return;
      if (widget.replaceCurrent) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScanResultScreen()),
        );
      }
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: ScreenHeader(
                    title: 'Adjust scan',
                    subtitle: 'Drag corners to refine the document.',
                    leading: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      background: Colors.white10,
                      foreground: Colors.white,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _CropCanvas(
                      imagePath: widget.imagePath,
                      corners: _corners,
                      rotation: _rotation,
                      onChanged: (corners) => setState(() => _corners = corners),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _tool('Crop', Icons.crop_rounded, () => setState(() => _corners = QuadCorners.full)),
                          const SizedBox(width: 10),
                          _tool('Rotate', Icons.rotate_90_degrees_ccw_rounded, () {
                            setState(() => _rotation = (_rotation + 90) % 360);
                          }),
                          const SizedBox(width: 10),
                          _tool('Enhance', Icons.auto_fix_high_rounded, () {
                            ref.read(scanSessionProvider.notifier).toggleEnhance();
                          }),
                        ],
                      ),
                      const SizedBox(height: 14),
                      StudioButton(
                        label: 'Preview scan  >',
                        enabled: _detected,
                        onPressed: _preview,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Polishing page…'),
        ],
      ),
    );
  }

  Widget _tool(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: AppColors.paperInk),
                const SizedBox(height: 4),
                Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.paperInk)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropCanvas extends StatelessWidget {
  const _CropCanvas({
    required this.imagePath,
    required this.corners,
    required this.rotation,
    required this.onChanged,
  });

  final String imagePath;
  final QuadCorners corners;
  final int rotation;
  final ValueChanged<QuadCorners> onChanged;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: (rotation / 90).round(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _QuadPainter(corners),
                ),
              ),
              ...List.generate(4, (index) {
                final point = corners.points[index];
                return Positioned(
                  left: point.dx * constraints.maxWidth - 16,
                  top: point.dy * constraints.maxHeight - 16,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final next = OffsetNorm(
                        point.dx + details.delta.dx / constraints.maxWidth,
                        point.dy + details.delta.dy / constraints.maxHeight,
                      ).clamp();
                      onChanged(corners.copyWithPoint(index, next));
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _QuadPainter extends CustomPainter {
  const _QuadPainter(this.corners);

  final QuadCorners corners;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(corners.topLeft.dx * size.width, corners.topLeft.dy * size.height)
      ..lineTo(corners.topRight.dx * size.width, corners.topRight.dy * size.height)
      ..lineTo(corners.bottomRight.dx * size.width, corners.bottomRight.dy * size.height)
      ..lineTo(corners.bottomLeft.dx * size.width, corners.bottomLeft.dy * size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _QuadPainter oldDelegate) => oldDelegate.corners != corners;
}
