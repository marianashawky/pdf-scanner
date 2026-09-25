import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import 'compress_screen.dart';
import 'merge_screen.dart';
import 'split_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            ScreenHeader(
              title: l10n.toolsTitle,
              subtitle: l10n.toolsSubtitle,
              leading: standalone
                  ? CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context))
                  : null,
            ),
            const SizedBox(height: 22),
            _ToolRow(
              icon: Icons.layers_outlined,
              title: l10n.mergePdfs,
              subtitle: l10n.mergeSub,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MergeScreen())),
            ),
            const SizedBox(height: 12),
            _ToolRow(
              icon: Icons.content_cut_rounded,
              title: l10n.splitPdf,
              subtitle: l10n.splitSub,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SplitScreen())),
            ),
            const SizedBox(height: 12),
            _ToolRow(
              icon: Icons.speed_rounded,
              title: l10n.compressPdf,
              subtitle: l10n.compressSub,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CompressScreen())),
            ),
            const SizedBox(height: 18),
            const PrivacyBanner(),
          ],
        ),
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
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
    final palette = StudioPalette.of(context);
    return StudioCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconWell(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: studioText(context: context, fontWeight: FontWeight.w700, color: palette.cardForeground),
                ),
                Text(
                  subtitle,
                  style: studioText(
                    context: context,
                    fontSize: 12,
                    color: palette.cardForeground.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.cardForeground.withValues(alpha: 0.55)),
        ],
      ),
    );
  }
}
