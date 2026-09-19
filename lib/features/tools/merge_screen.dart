import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../preview/pdf_preview_screen.dart';

class MergeScreen extends ConsumerStatefulWidget {
  const MergeScreen({super.key});

  @override
  ConsumerState<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends ConsumerState<MergeScreen> {
  final _selected = <StudioDocument>[];
  var _busy = false;

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return;
    setState(() => _busy = true);
    try {
      for (final file in result.files) {
        if (file.path == null) continue;
        final document = await ref.read(pdfServiceProvider).importPdf(file.path!);
        await ref.read(documentsProvider.notifier).add(document);
        _selected.add(document);
      }
      setState(() {});
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _merge() async {
    if (_selected.length < 2) return;
    setState(() => _busy = true);
    try {
      final document = await ref.read(pdfServiceProvider).mergePdfs(
            pdfPaths: _selected.map((doc) => doc.pdfPath).toList(),
            name: 'Merged ${_selected.length} PDFs',
            quality: ref.read(settingsProvider).quality,
          );
      await ref.read(documentsProvider.notifier).add(document);
      final count = await ref.read(settingsProvider.notifier).markSaved();
      await ref.read(adsServiceProvider).maybeShowInterstitial(count);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(documentId: document.id)),
      );
    } catch (error) {
      if (mounted) showStudioError(context, error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: Column(
                children: [
                  ScreenHeader(
                    title: 'Merge PDFs',
                    subtitle: 'Combine files in the order you want.',
                    leading: CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(height: 20),
                  DashedDropZone(
                    icon: Icons.layers_outlined,
                    title: 'Choose PDF files',
                    subtitle: 'Tap to browse your device',
                    onTap: _import,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: documents.isEmpty
                        ? const EmptyState(
                            title: 'No PDFs yet',
                            message: 'Import files or scan documents, then pick at least two to merge.',
                          )
                        : ReorderableListView(
                            onReorderItem: (oldIndex, newIndex) {
                              if (_selected.length < 2) return;
                              setState(() {
                                final item = _selected.removeAt(oldIndex.clamp(0, _selected.length - 1));
                                _selected.insert(newIndex.clamp(0, _selected.length), item);
                              });
                            },
                            children: [
                              for (final doc in documents)
                                Padding(
                                  key: ValueKey(doc.id),
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: StudioCard(
                                    onTap: () {
                                      setState(() {
                                        if (_selected.any((item) => item.id == doc.id)) {
                                          _selected.removeWhere((item) => item.id == doc.id);
                                        } else {
                                          _selected.add(doc);
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          _selected.any((item) => item.id == doc.id)
                                              ? Icons.check_circle_rounded
                                              : Icons.circle_outlined,
                                          color: StudioPalette.of(context).cardForeground,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(doc.fileName)),
                                        if (_selected.any((item) => item.id == doc.id))
                                          const Icon(Icons.drag_handle_rounded),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                  StudioButton(
                    label: 'Merge ${_selected.length} PDFs  >',
                    enabled: _selected.length >= 2,
                    onPressed: _merge,
                  ),
                ],
              ),
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Merging privately…'),
        ],
      ),
    );
  }
}
