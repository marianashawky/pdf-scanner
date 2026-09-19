import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../preview/pdf_preview_screen.dart';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  final _pages = <PendingPage>[];
  var _busy = false;

  Future<void> _pick() async {
    final allowed = await ref.read(permissionServiceProvider).ensurePhotos();
    if (!allowed && mounted) {
      showStudioError(context, 'Photo access is needed to import images.');
      return;
    }
    final files = await ImagePicker().pickMultiImage(imageQuality: 95);
    if (files.isEmpty) return;
    setState(() {
      _pages.addAll(
        files.map((file) => PendingPage(id: const Uuid().v4(), path: file.path)),
      );
    });
  }

  Future<void> _create() async {
    if (_pages.isEmpty) return;
    setState(() => _busy = true);
    try {
      final document = await ref.read(pdfServiceProvider).createFromImages(
            imagePaths: _pages.map((page) => page.path).toList(),
            name: 'Images ${_pages.length} pages',
            source: DocumentSource.images,
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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              child: Column(
                children: [
                  ScreenHeader(
                    title: 'Images to PDF',
                    subtitle: 'Arrange your images into one polished PDF.',
                    leading: CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(height: 22),
                  DashedDropZone(
                    icon: Icons.image_outlined,
                    title: 'Choose images',
                    subtitle: 'JPG, PNG, HEIC',
                    onTap: _pick,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _pages.isEmpty
                        ? const EmptyState(
                            title: 'Your selected pages will appear here',
                            message: 'Import one or more photos, then reorder before creating a PDF.',
                            icon: Icons.collections_outlined,
                          )
                        : ReorderableListView.builder(
                            itemCount: _pages.length,
                            onReorderItem: (oldIndex, newIndex) {
                              setState(() {
                                final item = _pages.removeAt(oldIndex);
                                _pages.insert(newIndex.clamp(0, _pages.length), item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final page = _pages[index];
                              return Padding(
                                key: ValueKey(page.id),
                                padding: const EdgeInsets.only(bottom: 10),
                                child: StudioCard(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(File(page.path), width: 56, height: 72, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text('Page ${index + 1}')),
                                      IconButton(
                                        onPressed: () => setState(() => _pages.removeAt(index)),
                                        icon: const Icon(Icons.delete_outline_rounded),
                                      ),
                                      const Icon(Icons.drag_handle_rounded),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  StudioButton(
                    label: 'Create PDF  >',
                    enabled: _pages.isNotEmpty,
                    onPressed: _create,
                  ),
                ],
              ),
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Creating PDF…'),
        ],
      ),
    );
  }
}
