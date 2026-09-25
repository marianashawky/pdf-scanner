import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'core/constants.dart';
import 'data/document_store.dart';
import 'data/models.dart';
import 'services/ads_service.dart';
import 'services/image_processing_service.dart';
import 'services/pdf_service.dart';
import 'services/permission_service.dart';
import 'services/share_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at startup');
});

final documentStoreProvider = Provider<DocumentStore>((ref) {
  return DocumentStore(ref.watch(sharedPreferencesProvider));
});

final imageProcessingProvider = Provider<ImageProcessingService>((ref) {
  return ImageProcessingService();
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService(ref.watch(documentStoreProvider));
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

final adsServiceProvider = Provider<AdsService>((ref) {
  final service = AdsService();
  ref.onDispose(service.dispose);
  return service;
});

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final documentsProvider = NotifierProvider<DocumentsNotifier, List<StudioDocument>>(DocumentsNotifier.new);

final scanSessionProvider = NotifierProvider<ScanSessionNotifier, ScanSession>(ScanSessionNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  DocumentStore get _store => ref.read(documentStoreProvider);

  @override
  AppSettings build() => _store.loadSettings();

  Future<void> _persist() => _store.saveSettings(state);

  Future<void> setTheme(ThemePreference theme) async {
    state = state.copyWith(themeMode: theme);
    await _persist();
  }

  Future<void> toggleTheme() {
    return setTheme(state.themeMode.isDark ? ThemePreference.light : ThemePreference.dark);
  }

  Future<void> setQuality(ScanQuality quality) async {
    state = state.copyWith(quality: quality);
    await _persist();
  }

  Future<void> setLocaleCode(String localeCode) async {
    state = state.copyWith(localeCode: localeCode);
    await _persist();
  }

  Future<void> setAutoEnhance(bool enabled) async {
    state = state.copyWith(autoEnhance: enabled);
    await _persist();
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasOnboarded: true);
    await _persist();
  }

  Future<int> markSaved() async {
    final next = state.saveCount + 1;
    state = state.copyWith(saveCount: next);
    await _persist();
    return next;
  }
}

class DocumentsNotifier extends Notifier<List<StudioDocument>> {
  DocumentStore get _store => ref.read(documentStoreProvider);

  @override
  List<StudioDocument> build() => _store.loadDocuments();

  Future<void> _persist() => _store.saveDocuments(state);

  Future<StudioDocument> add(StudioDocument document) async {
    state = [document, ...state.where((item) => item.id != document.id)];
    await _persist();
    return document;
  }

  Future<void> rename(String id, String name) async {
    state = [
      for (final doc in state)
        if (doc.id == id) doc.copyWith(name: name, updatedAt: DateTime.now()) else doc,
    ];
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    state = [
      for (final doc in state)
        if (doc.id == id) doc.copyWith(isFavorite: !doc.isFavorite) else doc,
    ];
    await _persist();
  }

  Future<void> remove(String id) async {
    final match = state.where((doc) => doc.id == id);
    if (match.isEmpty) return;
    await _store.deleteDocumentFiles(match.first);
    state = state.where((doc) => doc.id != id).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    for (final doc in state) {
      await _store.deleteDocumentFiles(doc);
    }
    state = [];
    await _persist();
  }

  StudioDocument? byId(String id) {
    final matches = state.where((doc) => doc.id == id);
    return matches.isEmpty ? null : matches.first;
  }
}

class ScanSessionNotifier extends Notifier<ScanSession> {
  static const _uuid = Uuid();

  @override
  ScanSession build() {
    final autoEnhance = ref.read(settingsProvider).autoEnhance;
    return ScanSession(autoEnhance: autoEnhance);
  }

  void reset() {
    final autoEnhance = ref.read(settingsProvider).autoEnhance;
    state = ScanSession(autoEnhance: autoEnhance);
  }

  void toggleEnhance() {
    state = state.copyWith(autoEnhance: !state.autoEnhance);
  }

  void setEnhance(bool enabled) {
    state = state.copyWith(autoEnhance: enabled);
  }

  void setCurrent(int index) {
    if (state.pages.isEmpty) return;
    state = state.copyWith(currentIndex: index.clamp(0, state.pages.length - 1));
  }

  void addPage(ScanPage page) {
    final pages = [...state.pages, page];
    state = state.copyWith(pages: pages, currentIndex: pages.length - 1);
  }

  ScanPage createPage(String path) {
    return ScanPage(id: _uuid.v4(), sourcePath: path, processedPath: path);
  }

  void updateCurrent(ScanPage page) {
    if (state.pages.isEmpty) return;
    final pages = [...state.pages];
    pages[state.currentIndex] = page;
    state = state.copyWith(pages: pages);
  }

  void rotateCurrent() {
    final current = state.current;
    if (current == null) return;
    updateCurrent(current.copyWith(rotation: (current.rotation + 90) % 360));
  }

  void filterCurrent(ScanFilter filter) {
    final current = state.current;
    if (current == null) return;
    updateCurrent(current.copyWith(filter: filter));
  }

  void removeAt(int index) {
    final pages = [...state.pages]..removeAt(index);
    state = state.copyWith(
      pages: pages,
      currentIndex: pages.isEmpty ? 0 : index.clamp(0, pages.length - 1),
    );
  }

  void reorder(int oldIndex, int newIndex) {
    final pages = [...state.pages];
    final item = pages.removeAt(oldIndex);
    pages.insert(newIndex.clamp(0, pages.length), item);
    state = state.copyWith(pages: pages, currentIndex: newIndex.clamp(0, pages.length - 1));
  }
}
