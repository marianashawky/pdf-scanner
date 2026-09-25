import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../preview/pdf_preview_screen.dart';
import 'crop_adjust_screen.dart';
import 'scan_camera_screen.dart';

class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({super.key});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  var _busy = false;

  Future<void> _reprocess() async {
    final session = ref.read(scanSessionProvider);
    final current = session.current;
    if (current == null) return;
    setState(() => _busy = true);
    try {
      final quality = ref.read(settingsProvider).quality;
      final bytes = await ref.read(imageProcessingProvider).processPage(
            sourcePath: current.sourcePath,
            corners: current.corners,
            rotation: current.rotation,
            filter: current.filter,
            quality: quality,
            enhance: session.autoEnhance || current.filter == ScanFilter.color,
          );
      final cache = await ref.read(documentStoreProvider).cacheDir();
      final path = await ref.read(imageProcessingProvider).writeProcessed(bytes: bytes, directory: cache);
      ref.read(scanSessionProvider.notifier).updateCurrent(current.copyWith(processedPath: path));
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleEnhance() async {
    ref.read(scanSessionProvider.notifier).toggleEnhance();
    await _reprocess();
  }

  Future<void> _save({required bool shareAfter}) async {
    final session = ref.read(scanSessionProvider);
    final l10n = AppLocalizations.of(context);
    if (session.pages.isEmpty) return;
    setState(() => _busy = true);
    try {
      final stamp = DateTime.now();
      final document = await ref.read(pdfServiceProvider).createFromImages(
            imagePaths: session.pages.map((page) => page.processedPath).toList(),
            name:
                '${l10n.scanNamePrefix} ${stamp.month}-${stamp.day} ${stamp.hour}.${stamp.minute.toString().padLeft(2, '0')}',
            source: DocumentSource.scan,
          );
      await ref.read(documentsProvider.notifier).add(document);
      final count = await ref.read(settingsProvider.notifier).markSaved();
      await ref.read(adsServiceProvider).maybeShowInterstitial(count);
      ref.read(scanSessionProvider.notifier).reset();
      if (!mounted) return;
      if (shareAfter) {
        await ref.read(shareServiceProvider).shareDocument(document);
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(documentId: document.id)),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(scanSessionProvider);
    final current = session.current;
    final l10n = AppLocalizations.of(context);
    final enhance = session.autoEnhance;

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
                    title: l10n.preview,
                    subtitle: current == null
                        ? l10n.noPagesYet
                        : l10n.pageOf(session.currentIndex + 1, session.pages.length),
                    leading: CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      background: Colors.white10,
                      foreground: Colors.white,
                      onTap: () => Navigator.pop(context),
                    ),
                    trailing: CircleIconButton(
                      icon: Icons.add_rounded,
                      background: Colors.white10,
                      foreground: Colors.white,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: current == null
                      ? Padding(
                          padding: const EdgeInsets.all(22),
                          child: EmptyState(
                            title: l10n.noPagePreview,
                            message: l10n.captureToPolish,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: PhotoView(
                              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                              imageProvider: FileImage(File(current.processedPath)),
                            ),
                          ),
                        ),
                ),
                if (session.pages.length > 1)
                  SizedBox(
                    height: 88,
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                      itemCount: session.pages.length,
                      onReorderItem: ref.read(scanSessionProvider.notifier).reorder,
                      itemBuilder: (context, index) {
                        final page = session.pages[index];
                        final selected = index == session.currentIndex;
                        return Padding(
                          key: ValueKey(page.id),
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => ref.read(scanSessionProvider.notifier).setCurrent(index),
                            child: Container(
                              width: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(File(page.processedPath), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                  child: Column(
                    children: [
                      if (current != null) ...[
                        FilterSelector(
                          value: current.filter,
                          onChanged: (filter) async {
                            ref.read(scanSessionProvider.notifier).filterCurrent(filter);
                            await _reprocess();
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _mini(l10n.crop, Icons.crop_rounded, false, () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CropAdjustScreen(
                                    imagePath: current.sourcePath,
                                    replaceCurrent: true,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            _mini(l10n.enhance, Icons.auto_fix_high_rounded, enhance, _toggleEnhance),
                            const SizedBox(width: 8),
                            _mini(l10n.rotate, Icons.rotate_90_degrees_ccw_rounded, false, () async {
                              ref.read(scanSessionProvider.notifier).rotateCurrent();
                              await _reprocess();
                            }),
                            const SizedBox(width: 8),
                            _mini(l10n.delete, Icons.delete_outline_rounded, false, () {
                              ref.read(scanSessionProvider.notifier).removeAt(session.currentIndex);
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: StudioButton(
                              label: l10n.save,
                              icon: Icons.download_outlined,
                              primary: false,
                              enabled: current != null,
                              onPressed: () => _save(shareAfter: false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StudioButton(
                              label: l10n.share,
                              icon: Icons.ios_share_rounded,
                              enabled: current != null,
                              onPressed: () => _save(shareAfter: true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_busy) LoadingScrim(label: enhance ? l10n.enhancing : l10n.workingLocally),
        ],
      ),
    );
  }

  Widget _mini(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: active ? AppColors.primaryForeground : AppColors.paperInk, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: studioText(
                    context: context,
                    color: active ? AppColors.primaryForeground : AppColors.paperInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
