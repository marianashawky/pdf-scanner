import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';
import '../scan/scan_camera_screen.dart';
import '../search/search_screen.dart';

class FilesScreen extends ConsumerWidget {
  const FilesScreen({super.key, this.standalone = false});

  final bool standalone;

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: true,
      );
      if (result == null) return;
      for (final file in result.files) {
        if (file.path == null) continue;
        final document = await ref.read(pdfServiceProvider).importPdf(file.path!);
        await ref.read(documentsProvider.notifier).add(document);
      }
    } catch (error) {
      if (context.mounted) showStudioError(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsProvider);
    final favorites = documents.where((doc) => doc.isFavorite).toList();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
          children: [
            ScreenHeader(
              title: l10n.recentFiles,
              subtitle: l10n.storedSecurely,
              leading: standalone
                  ? CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context))
                  : null,
              trailing: CircleIconButton(
                icon: Icons.more_horiz_rounded,
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.search_rounded),
                            title: Text(l10n.searchDocuments),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.picture_as_pdf_outlined),
                            title: Text(l10n.importPdf),
                            onTap: () {
                              Navigator.pop(context);
                              _import(context, ref);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (favorites.isNotEmpty) ...[
              const SizedBox(height: 22),
              SectionTitle(title: l10n.favorites),
              const SizedBox(height: 10),
              ...favorites.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DocumentTile(
                    document: doc,
                    onTap: () => openDocument(context, doc),
                    onMenu: () => showDocumentActions(context, ref, doc),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SectionTitle(title: l10n.files),
            const SizedBox(height: 10),
            if (documents.isEmpty)
              EmptyState(
                title: l10n.noDocumentsYet,
                message: l10n.emptyDocsMessage,
                actionLabel: l10n.scanDocument,
                onAction: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                ),
              )
            else
              ...documents.map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DocumentTile(
                    document: doc,
                    onTap: () => openDocument(context, doc),
                    onMenu: () => showDocumentActions(context, ref, doc),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
