import 'package:share_plus/share_plus.dart';

import '../data/models.dart';

class ShareService {
  Future<void> shareDocument(StudioDocument document) {
    return Share.shareXFiles(
      [XFile(document.pdfPath, mimeType: 'application/pdf', name: document.fileName)],
      subject: document.fileName,
      text: document.name,
    );
  }

  Future<void> shareFile(String path, {String? name}) {
    return Share.shareXFiles(
      [XFile(path, name: name)],
    );
  }
}
