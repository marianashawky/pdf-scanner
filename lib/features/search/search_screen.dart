import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_widgets.dart';
import '../../providers.dart';
import '../common/document_actions.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(documentsProvider);
    final results = documents.where((doc) {
      return doc.name.toLowerCase().contains(_query.toLowerCase()) ||
          doc.source.label.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            children: [
              ScreenHeader(
                title: 'Search',
                subtitle: 'Find a document on this device.',
                leading: CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _controller,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: results.isEmpty
                    ? ListView(
                        children: [
                          EmptyState(
                            icon: Icons.search_rounded,
                            title: _query.isEmpty ? 'Start typing' : 'No matches',
                            message: _query.isEmpty
                                ? 'Search recent scans, merges, and imported PDFs.'
                                : 'Nothing on this device matches “$_query”.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final doc = results[index];
                          return DocumentTile(
                            document: doc,
                            onTap: () => openDocument(context, doc),
                            onMenu: () => showDocumentActions(context, ref, doc),
                          );
                        },
                      ),
              ),
              Text(
                'Search stays local.',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.darkMutedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
