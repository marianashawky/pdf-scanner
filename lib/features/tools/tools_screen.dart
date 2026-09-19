import 'package:flutter/material.dart';

import '../../core/widgets/studio_widgets.dart';
import 'compress_screen.dart';
import 'merge_screen.dart';
import 'split_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            ScreenHeader(
              title: 'PDF tools',
              subtitle: 'Everything you need, processed privately.',
              leading: standalone
                  ? CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context))
                  : null,
            ),
            const SizedBox(height: 22),
            _ToolRow(
              icon: Icons.layers_outlined,
              title: 'Merge PDFs',
              subtitle: 'Combine multiple documents',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MergeScreen())),
            ),
            const SizedBox(height: 12),
            _ToolRow(
              icon: Icons.content_cut_rounded,
              title: 'Split PDF',
              subtitle: 'Extract or remove pages',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SplitScreen())),
            ),
            const SizedBox(height: 12),
            _ToolRow(
              icon: Icons.speed_rounded,
              title: 'Compress PDF',
              subtitle: 'Make files easier to share',
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
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
