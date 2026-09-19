import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../preview/pdf_preview_screen.dart';

Future<void> openDocument(BuildContext context, StudioDocument document) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PdfPreviewScreen(documentId: document.id)),
  );
}

Future<void> showDocumentActions(BuildContext context, WidgetRef ref, StudioDocument document) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: StudioPalette.of(context).card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                document.fileName,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.paperInk),
              ),
              const SizedBox(height: 12),
              _sheetItem(Icons.open_in_full_rounded, 'Preview', () {
                Navigator.pop(context);
                openDocument(context, document);
              }),
              _sheetItem(Icons.drive_file_rename_outline_rounded, 'Rename', () {
                Navigator.pop(context);
                renameDocument(context, ref, document);
              }),
              _sheetItem(Icons.ios_share_rounded, 'Share', () {
                Navigator.pop(context);
                ref.read(shareServiceProvider).shareDocument(document);
              }),
              _sheetItem(
                document.isFavorite ? Icons.bookmark_remove_outlined : Icons.bookmark_border_rounded,
                document.isFavorite ? 'Remove favorite' : 'Add to favorites',
                () {
                  Navigator.pop(context);
                  ref.read(documentsProvider.notifier).toggleFavorite(document.id);
                },
              ),
              _sheetItem(Icons.delete_outline_rounded, 'Delete', () {
                Navigator.pop(context);
                confirmDelete(context, ref, document);
              }, danger: true),
            ],
          ),
        ),
      );
    },
  );
}

Widget _sheetItem(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
  return ListTile(
    onTap: onTap,
    leading: Icon(icon, color: danger ? AppColors.danger : AppColors.paperInk),
    title: Text(
      label,
      style: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: danger ? AppColors.danger : AppColors.paperInk,
      ),
    ),
  );
}

Future<void> renameDocument(BuildContext context, WidgetRef ref, StudioDocument document) async {
  final controller = TextEditingController(text: document.name);
  final next = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Rename PDF'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Document name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
  if (next != null && next.isNotEmpty) {
    await ref.read(documentsProvider.notifier).rename(document.id, next);
  }
}

Future<void> confirmDelete(BuildContext context, WidgetRef ref, StudioDocument document) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete document?'),
        content: Text('${document.fileName} will be removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      );
    },
  );
  if (confirmed == true) {
    await ref.read(documentsProvider.notifier).remove(document.id);
  }
}

Future<T?> showStudioError<T>(BuildContext context, Object error) {
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Something went wrong'),
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      );
    },
  );
}
