import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/studio_widgets.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../preview/pdf_preview_screen.dart';

class SplitScreen extends ConsumerStatefulWidget {
  const SplitScreen({super.key});

  @override
  ConsumerState<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends ConsumerState<SplitScreen> {
  StudioDocument? _document;
  final _keep = <int>{};
  var _pageCount = 0;
  var _busy = false;

  Future<void> _select(StudioDocument document) async {
    setState(() {
      _document = document;
      _pageCount = document.pageCount;
      _keep
        ..clear()
        ..addAll(List.generate(document.pageCount, (index) => index));
    });
  }

  Future<void> _split() async {
    final document = _document;
    if (document == null || _keep.isEmpty) return;
    setState(() => _busy = true);
    try {
      final created = await ref.read(pdfServiceProvider).splitPdf(
            pdfPath: document.pdfPath,
            keepIndexes: _keep.toList()..sort(),
            name: '${document.name} split',
            quality: ref.read(settingsProvider).quality,
          );
      await ref.read(documentsProvider.notifier).add(created);
      final count = await ref.read(settingsProvider.notifier).markSaved();
      await ref.read(adsServiceProvider).maybeShowInterstitial(count);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(documentId: created.id)),
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
                    title: 'Split PDF',
                    subtitle: 'Extract or remove pages.',
                    leading: CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: _document == null
                        ? ListView(
                            children: [
                              if (documents.isEmpty)
                                const EmptyState(
                                  title: 'Nothing to split',
                                  message: 'Scan or import a PDF first, then choose the pages to keep.',
                                )
                              else
                                ...documents.map(
                                  (doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: DocumentTile(
                                      document: doc,
                                      onTap: () => _select(doc),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              DocumentTile(document: _document!, onTap: () {}),
                              const SizedBox(height: 16),
                              const SectionTitle(title: 'Pages to keep'),
                              const SizedBox(height: 10),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.8,
                                  ),
                                  itemCount: _pageCount,
                                  itemBuilder: (_, index) {
                                    final selected = _keep.contains(index);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selected) {
                                            _keep.remove(index);
                                          } else {
                                            _keep.add(index);
                                          }
                                        });
                                      },
                                      child: StudioCard(
                                        color: selected ? const Color(0xFFE8FAF7) : null,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(selected ? Icons.check_circle_rounded : Icons.crop_portrait_rounded),
                                            const SizedBox(height: 8),
                                            Text('Page ${index + 1}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (_document != null)
                    StudioButton(
                      label: 'Create split PDF  >',
                      enabled: _keep.isNotEmpty,
                      onPressed: _split,
                    ),
                ],
              ),
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Splitting privately…'),
        ],
      ),
    );
  }
}
