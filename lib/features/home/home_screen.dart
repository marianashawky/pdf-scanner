import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/paper_visual.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../files/files_screen.dart';
import '../image_to_pdf/image_to_pdf_screen.dart';
import '../scan/scan_camera_screen.dart';
import '../search/search_screen.dart';
import '../tools/tools_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = StudioPalette.of(context);
    final documents = ref.watch(documentsProvider);
    final recent = documents.take(3).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            sliver: SliverList.list(
              children: [
                ScreenHeader(
                  eyebrow: greetingFor(DateTime.now()),
                  title: 'Document studio',
                  trailing: CircleIconButton(
                    icon: Icons.more_horiz_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _HeroCard(
                  onScan: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                  ),
                ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.04, curve: Curves.easeOutCubic),
                const SizedBox(height: 28),
                const SectionTitle(title: 'Quick actions'),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.18,
                  children: [
                    _QuickAction(
                      icon: Icons.photo_camera_outlined,
                      title: 'Scan document',
                      subtitle: 'Camera scan',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.image_outlined,
                      title: 'Image to PDF',
                      subtitle: 'Photos to pages',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ImageToPdfScreen()),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.auto_fix_high_outlined,
                      title: 'PDF tools',
                      subtitle: 'Merge, split & more',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ToolsScreen(standalone: true)),
                      ),
                    ),
                    _QuickAction(
                      icon: Icons.folder_open_outlined,
                      title: 'Recent files',
                      subtitle: '${documents.length} documents',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FilesScreen(standalone: true)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionTitle(
                  title: 'Recent files',
                  action: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FilesScreen(standalone: true)),
                    ),
                    child: Text(
                      'See all',
                      style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  EmptyState(
                    title: 'No documents yet',
                    message: 'Scan a page or import photos to start your private studio.',
                    actionLabel: 'Scan document',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                    ),
                  )
                else
                  ...recent.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DocumentTile(
                        document: doc,
                        onTap: () => openDocument(context, doc),
                        onMenu: () => showDocumentActions(context, ref, doc),
                      ),
                    ),
                  ),
                const SizedBox(height: 88),
                Text(
                  'Stored securely on this device.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontSize: 12, color: palette.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12181F),
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 36, offset: Offset(0, 18)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C242C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'READY TO CAPTURE',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Turn paper into\nperfect PDF.',
            style: GoogleFonts.manrope(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Auto-detect edges, enhance clarity, and export in seconds.',
            style: GoogleFonts.manrope(fontSize: 14, height: 1.4, color: AppColors.darkMutedForeground),
          ),
          const SizedBox(height: 20),
          StudioButton(
            label: 'Scan document',
            icon: Icons.photo_camera_outlined,
            onPressed: onScan,
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.bottomCenter,
            child: PaperVisual(size: 180),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWell(icon: icon),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.cardForeground,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: palette.cardForeground.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
