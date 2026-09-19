import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../preview/pdf_preview_screen.dart';

class CompressScreen extends ConsumerStatefulWidget {
  const CompressScreen({super.key});

  @override
  ConsumerState<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends ConsumerState<CompressScreen> {
  StudioDocument? _document;
  var _quality = ScanQuality.compact;
  var _busy = false;

  Future<void> _compress() async {
    final document = _document;
    if (document == null) return;
    setState(() => _busy = true);
    try {
      final created = await ref.read(pdfServiceProvider).compressPdf(
            pdfPath: document.pdfPath,
            name: '${document.name} compact',
            quality: _quality,
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
                    title: 'Compress PDF',
                    subtitle: 'Make files easier to share.',
                    leading: CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView(
                      children: [
                        if (_document == null)
                          ...[
                            if (documents.isEmpty)
                              const EmptyState(
                                title: 'No file to compress',
                                message: 'Choose a local PDF and we will rebuild it at a smaller size.',
                              )
                            else
                              ...documents.map(
                                (doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: DocumentTile(
                                    document: doc,
                                    onTap: () => setState(() => _document = doc),
                                  ),
                                ),
                              ),
                          ]
                        else ...[
                          DocumentTile(document: _document!, onTap: () {}),
                          const SizedBox(height: 18),
                          const SectionTitle(title: 'Target size'),
                          const SizedBox(height: 10),
                          ...ScanQuality.values.map((quality) {
                            final selected = quality == _quality;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: StudioCard(
                                onTap: () => setState(() => _quality = quality),
                                child: Row(
                                  children: [
                                    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(quality.label),
                                          Text(quality.subtitle, style: Theme.of(context).textTheme.bodySmall),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                  if (_document != null)
                    StudioButton(
                      label: 'Compress PDF  >',
                      onPressed: _compress,
                    ),
                ],
              ),
            ),
          ),
          if (_busy) const LoadingScrim(label: 'Compressing locally…'),
        ],
      ),
    );
  }
}
