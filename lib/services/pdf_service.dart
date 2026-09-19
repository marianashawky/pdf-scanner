import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../data/document_store.dart';
import '../data/models.dart';

class PdfService {
  PdfService(this._store);

  final DocumentStore _store;
  static const _uuid = Uuid();

  Future<StudioDocument> createFromImages({
    required List<String> imagePaths,
    required String name,
    required DocumentSource source,
  }) async {
    if (imagePaths.isEmpty) {
      throw StateError('Add at least one page to create a PDF.');
    }
    final doc = pw.Document();
    Uint8List? thumb;
    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      thumb ??= bytes;
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return _persist(document: doc, name: name, pageCount: imagePaths.length, source: source, thumbBytes: thumb);
  }

  Future<StudioDocument> mergePdfs({
    required List<String> pdfPaths,
    required String name,
    required ScanQuality quality,
  }) async {
    final pages = <Uint8List>[];
    for (final path in pdfPaths) {
      pages.addAll(await rasterize(path, quality: quality));
    }
    if (pages.isEmpty) {
      throw StateError('Those PDFs did not contain readable pages.');
    }
    return _fromRasters(pages, name, DocumentSource.merge);
  }

  Future<StudioDocument> splitPdf({
    required String pdfPath,
    required List<int> keepIndexes,
    required String name,
    required ScanQuality quality,
  }) async {
    final rasters = await rasterize(pdfPath, quality: quality);
    final selected = [
      for (final index in keepIndexes)
        if (index >= 0 && index < rasters.length) rasters[index],
    ];
    if (selected.isEmpty) {
      throw StateError('Select at least one page to keep.');
    }
    return _fromRasters(selected, name, DocumentSource.split);
  }

  Future<StudioDocument> compressPdf({
    required String pdfPath,
    required String name,
    required ScanQuality quality,
  }) async {
    final rasters = await rasterize(pdfPath, quality: quality);
    if (rasters.isEmpty) {
      throw StateError('Could not compress that PDF.');
    }
    return _fromRasters(rasters, name, DocumentSource.compress);
  }

  Future<List<Uint8List>> rasterize(String pdfPath, {required ScanQuality quality}) async {
    final bytes = await File(pdfPath).readAsBytes();
    final dpi = switch (quality) {
      ScanQuality.compact => 90.0,
      ScanQuality.balanced => 120.0,
      ScanQuality.high => 150.0,
    };
    final pages = <Uint8List>[];
    await for (final raster in Printing.raster(bytes, dpi: dpi)) {
      pages.add(await raster.toPng());
    }
    return pages;
  }

  Future<StudioDocument> importPdf(String path) async {
    final bytes = await File(path).readAsBytes();
    final pages = <Uint8List>[];
    await for (final raster in Printing.raster(bytes, dpi: 72)) {
      pages.add(await raster.toPng());
      if (pages.length >= 80) break;
    }
    final name = p.basenameWithoutExtension(path);
    if (pages.isEmpty) {
      final files = await _store.filesDir();
      final id = _uuid.v4();
      final dest = File(p.join(files.path, '$id.pdf'));
      await dest.writeAsBytes(bytes, flush: true);
      return StudioDocument(
        id: id,
        name: name,
        pdfPath: dest.path,
        pageCount: 1,
        sizeBytes: bytes.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        source: DocumentSource.import,
      );
    }
    return _fromRasters(pages, name, DocumentSource.import);
  }

  Future<StudioDocument> _fromRasters(
    List<Uint8List> pages,
    String name,
    DocumentSource source,
  ) async {
    final doc = pw.Document();
    for (final bytes in pages) {
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    return _persist(
      document: doc,
      name: name,
      pageCount: pages.length,
      source: source,
      thumbBytes: pages.first,
    );
  }

  Future<StudioDocument> _persist({
    required pw.Document document,
    required String name,
    required int pageCount,
    required DocumentSource source,
    Uint8List? thumbBytes,
  }) async {
    final id = _uuid.v4();
    final files = await _store.filesDir();
    final thumbs = await _store.thumbsDir();
    final pdfPath = p.join(files.path, '$id.pdf');
    final bytes = await document.save();
    await File(pdfPath).writeAsBytes(bytes, flush: true);

    String? thumbPath;
    if (thumbBytes != null) {
      thumbPath = p.join(thumbs.path, '$id.jpg');
      await File(thumbPath).writeAsBytes(thumbBytes, flush: true);
    }

    final now = DateTime.now();
    return StudioDocument(
      id: id,
      name: name,
      pdfPath: pdfPath,
      thumbnailPath: thumbPath,
      pageCount: pageCount,
      sizeBytes: bytes.length,
      createdAt: now,
      updatedAt: now,
      source: source,
    );
  }
}
