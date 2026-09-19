import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';

class PdfPreviewScreen extends ConsumerStatefulWidget {
  const PdfPreviewScreen({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  var _pages = const <Uint8List>[];
  var _index = 0;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final document = ref.read(documentsProvider.notifier).byId(widget.documentId);
    if (document == null) {
      setState(() {
        _loading = false;
        _error = 'This document is no longer on the device.';
      });
      return;
    }
    try {
      final rasters = await ref.read(pdfServiceProvider).rasterize(
            document.pdfPath,
            quality: ref.read(settingsProvider).quality,
          );
      if (!mounted) return;
      setState(() {
        _pages = rasters;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = ref.watch(documentsProvider).where((doc) => doc.id == widget.documentId);
    final current = document.isEmpty ? null : document.first;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ScreenHeader(
                title: 'Preview',
                subtitle: current == null
                    ? 'Document'
                    : '${current.fileName} · ${pageLabel(current.pageCount)}',
                leading: CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  background: Colors.white10,
                  foreground: Colors.white,
                  onTap: () => Navigator.pop(context),
                ),
                trailing: current == null
                    ? null
                    : CircleIconButton(
                        icon: Icons.more_horiz_rounded,
                        background: Colors.white10,
                        foreground: Colors.white,
                        onTap: () => showDocumentActions(context, ref, current),
                      ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(22),
                          child: EmptyState(title: 'Preview unavailable', message: _error!),
                        )
                      : PageView.builder(
                          itemCount: _pages.length,
                          onPageChanged: (value) => setState(() => _index = value),
                          itemBuilder: (_, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: PhotoView(
                                  backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                                  imageProvider: MemoryImage(_pages[index]),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            if (_pages.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Page ${_index + 1} of ${_pages.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            if (current != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: StudioButton(
                        label: 'Rename',
                        icon: Icons.drive_file_rename_outline_rounded,
                        primary: false,
                        onPressed: () => renameDocument(context, ref, current),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StudioButton(
                        label: 'Share',
                        icon: Icons.ios_share_rounded,
                        onPressed: () => ref.read(shareServiceProvider).shareDocument(current),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
