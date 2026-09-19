import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PaperVisual extends StatelessWidget {
  const PaperVisual({
    super.key,
    this.size = 168,
    this.stacked = true,
    this.icon = Icons.notes_rounded,
  });

  final double size;
  final bool stacked;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (stacked)
            Transform.translate(
              offset: const Offset(16, 10),
              child: Transform.rotate(
                angle: 0.16,
                child: _Sheet(size: size * 0.72, faded: true),
              ),
            ),
          _Sheet(size: size * 0.78, icon: icon),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.size, this.icon, this.faded = false});

  final double size;
  final IconData? icon;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.08,
      decoration: BoxDecoration(
        color: faded ? const Color(0xFFE7EBEE) : AppColors.paper,
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: faded ? 0.12 : 0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: size * 0.16, vertical: size * 0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size * 0.28,
            height: 7,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Spacer(),
          if (icon != null)
            Icon(icon, size: size * 0.22, color: AppColors.studio)
          else ...[
            _line(size * 0.46),
            const SizedBox(height: 8),
            _line(size * 0.34),
          ],
          const Spacer(),
          Row(
            children: List.generate(
              3,
              (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: AppColors.studio,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(double width) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.studio.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class ScanMarkIcon extends StatelessWidget {
  const ScanMarkIcon({super.key, this.color = Colors.white, this.size = 26});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.crop_free_rounded, color: color, size: size);
  }
}
