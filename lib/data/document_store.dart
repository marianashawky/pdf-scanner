import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class DocumentStore {
  DocumentStore(this._prefs);

  final SharedPreferences _prefs;
  static const _docsKey = 'studio_documents_v1';
  static const _settingsKey = 'studio_settings_v1';

  Future<Directory> documentsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'studio'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> filesDir() async {
    final dir = Directory(p.join((await documentsDir()).path, 'files'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> thumbsDir() async {
    final dir = Directory(p.join((await documentsDir()).path, 'thumbs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> cacheDir() async {
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, 'scan_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  List<StudioDocument> loadDocuments() {
    final raw = _prefs.getString(_docsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => StudioDocument.fromJson(item as Map<String, dynamic>))
        .where((doc) => File(doc.pdfPath).existsSync())
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveDocuments(List<StudioDocument> documents) async {
    final encoded = jsonEncode(documents.map((doc) => doc.toJson()).toList());
    await _prefs.setString(_docsKey, encoded);
  }

  AppSettings loadSettings() {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) {
    return _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<void> deleteDocumentFiles(StudioDocument document) async {
    final pdf = File(document.pdfPath);
    if (await pdf.exists()) {
      await pdf.delete();
    }
    if (document.thumbnailPath != null) {
      final thumb = File(document.thumbnailPath!);
      if (await thumb.exists()) {
        await thumb.delete();
      }
    }
  }
}
