import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models.dart';
import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class StudioScaffold extends StatelessWidget {
  const StudioScaffold({
    super.key,
    required this.child,
    this.padding,
    this.bottom,
    this.floating,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Widget? bottom;
  final Widget? floating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: child,
              ),
            ),
            ?bottom,
          ],
        ),
      ),
      floatingActionButton: floating,
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.eyebrow,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Text(
                  eyebrow!,
                  style: studioText(
                    context: context,
                    fontSize: 13,
                    color: palette.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              Text(
                title,
                style: studioText(
                  context: context,
                  fontSize: 32,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.1,
                  color: palette.foreground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: studioText(
                    context: context,
                    fontSize: 14,
                    height: 1.4,
                    color: palette.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background,
    this.foreground,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Material(
      color: background ?? palette.card.withValues(alpha: 0.72),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 20, color: foreground ?? palette.foreground),
        ),
      ),
    );
  }
}

class StudioButton extends StatelessWidget {
  const StudioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.primary = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool primary;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final effective = enabled ? onPressed : null;
    final background = primary ? AppColors.primary : palette.muted;
    final foreground = primary ? AppColors.primaryForeground : palette.foreground;
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: studioText(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: foreground,
              context: context,
            ),
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: primary && enabled
              ? const [
                  BoxShadow(color: AppColors.primaryGlow, blurRadius: 28, offset: Offset(0, 12)),
                ]
              : const [],
        ),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: effective,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.radius = 28,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: color ?? palette.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: palette.softShadow, blurRadius: 28, offset: const Offset(0, 14)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class IconWell extends StatelessWidget {
  const IconWell({
    super.key,
    required this.icon,
    this.size = 42,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? palette.iconWell,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.46, color: foreground ?? palette.iconWellForeground),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: studioText(
              context: context,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: palette.foreground,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

class DocumentTile extends StatelessWidget {
  const DocumentTile({
    super.key,
    required this.document,
    required this.onTap,
    this.onMenu,
  });

  final StudioDocument document;
  final VoidCallback onTap;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    final l10n = AppLocalizations.of(context);
    return StudioCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconWell(
            icon: document.isFavorite ? Icons.bookmark_rounded : Icons.description_outlined,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: studioText(
                    context: context,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: palette.cardForeground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'PDF · ${l10n.pageLabel(document.pageCount)} · ${formatBytes(document.sizeBytes)}',
                  style: studioText(
                    context: context,
                    fontSize: 12,
                    color: palette.cardForeground.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatRelativeDate(document.updatedAt, l10n),
            style: studioText(
              context: context,
              fontSize: 12,
              color: palette.cardForeground.withValues(alpha: 0.65),
            ),
          ),
          if (onMenu != null)
            IconButton(
              onPressed: onMenu,
              icon: Icon(Icons.more_horiz_rounded, color: palette.cardForeground.withValues(alpha: 0.65)),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.description_outlined,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = StudioPalette.of(context);
    return StudioCard(
      color: palette.muted.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.85 : 0.45),
      child: Column(
        children: [
          IconWell(icon: icon, size: 56, background: AppColors.primary, foreground: AppColors.primaryForeground),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: studioText(
              context: context,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: studioText(context: context, fontSize: 13, height: 1.45, color: palette.mutedForeground),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            StudioButton(label: actionLabel!, onPressed: onAction, expanded: false),
          ],
        ],
      ),
    );
  }
}

class DashedDropZone extends StatelessWidget {
  const DashedDropZone({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashPainter(color: AppColors.primary.withValues(alpha: 0.35)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
          decoration: BoxDecoration(
            color: const Color(0xFFE8FAF7),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            children: [
              IconWell(icon: icon, size: 52, background: AppColors.primary, foreground: AppColors.primaryForeground),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.paperInk),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.manrope(fontSize: 13, color: AppColors.lightMutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28));
    final path = Path()..addRRect(rrect);
    const dash = 7.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) => oldDelegate.color != color;
}

class PrivacyBanner extends StatelessWidget {
  const PrivacyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.studio,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const IconWell(
            icon: Icons.verified_user_outlined,
            background: Color(0xFF222A33),
            foreground: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privateWorkspace,
                  style: studioText(
                    context: context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkForeground,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.privateWorkspaceBody,
                  style: studioText(
                    context: context,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.darkMutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSelector extends StatelessWidget {
  const FilterSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ScanFilter value;
  final ValueChanged<ScanFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: ScanFilter.values.map((filter) {
        final selected = filter == value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.filterLabel(filter),
                  textAlign: TextAlign.center,
                  style: studioText(
                    context: context,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.primaryForeground : AppColors.paperInk,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LoadingScrim extends StatelessWidget {
  const LoadingScrim({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: StudioCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                label,
                style: studioText(context: context, fontWeight: FontWeight.w600, color: AppColors.paperInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
