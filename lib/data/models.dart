import 'package:flutter/foundation.dart';

import '../core/constants.dart';

@immutable
class QuadCorners {
  const QuadCorners({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  final OffsetNorm topLeft;
  final OffsetNorm topRight;
  final OffsetNorm bottomRight;
  final OffsetNorm bottomLeft;

  static const full = QuadCorners(
    topLeft: OffsetNorm(0.04, 0.04),
    topRight: OffsetNorm(0.96, 0.04),
    bottomRight: OffsetNorm(0.96, 0.96),
    bottomLeft: OffsetNorm(0.04, 0.96),
  );

  List<OffsetNorm> get points => [topLeft, topRight, bottomRight, bottomLeft];

  QuadCorners copyWithPoint(int index, OffsetNorm value) {
    return QuadCorners(
      topLeft: index == 0 ? value : topLeft,
      topRight: index == 1 ? value : topRight,
      bottomRight: index == 2 ? value : bottomRight,
      bottomLeft: index == 3 ? value : bottomLeft,
    );
  }

  Map<String, dynamic> toJson() => {
        'tl': topLeft.toJson(),
        'tr': topRight.toJson(),
        'br': bottomRight.toJson(),
        'bl': bottomLeft.toJson(),
      };

  factory QuadCorners.fromJson(Map<String, dynamic> json) {
    return QuadCorners(
      topLeft: OffsetNorm.fromJson(json['tl'] as Map<String, dynamic>),
      topRight: OffsetNorm.fromJson(json['tr'] as Map<String, dynamic>),
      bottomRight: OffsetNorm.fromJson(json['br'] as Map<String, dynamic>),
      bottomLeft: OffsetNorm.fromJson(json['bl'] as Map<String, dynamic>),
    );
  }
}

@immutable
class OffsetNorm {
  const OffsetNorm(this.dx, this.dy);

  final double dx;
  final double dy;

  OffsetNorm clamp() => OffsetNorm(dx.clamp(0.0, 1.0), dy.clamp(0.0, 1.0));

  Map<String, dynamic> toJson() => {'x': dx, 'y': dy};

  factory OffsetNorm.fromJson(Map<String, dynamic> json) {
    return OffsetNorm((json['x'] as num).toDouble(), (json['y'] as num).toDouble());
  }
}

@immutable
class ScanPage {
  const ScanPage({
    required this.id,
    required this.sourcePath,
    required this.processedPath,
    this.rotation = 0,
    this.filter = ScanFilter.original,
    this.corners = QuadCorners.full,
  });

  final String id;
  final String sourcePath;
  final String processedPath;
  final int rotation;
  final ScanFilter filter;
  final QuadCorners corners;

  ScanPage copyWith({
    String? processedPath,
    int? rotation,
    ScanFilter? filter,
    QuadCorners? corners,
  }) {
    return ScanPage(
      id: id,
      sourcePath: sourcePath,
      processedPath: processedPath ?? this.processedPath,
      rotation: rotation ?? this.rotation,
      filter: filter ?? this.filter,
      corners: corners ?? this.corners,
    );
  }
}

@immutable
class ScanSession {
  const ScanSession({
    this.pages = const [],
    this.autoEnhance = true,
    this.currentIndex = 0,
  });

  final List<ScanPage> pages;
  final bool autoEnhance;
  final int currentIndex;

  ScanPage? get current => pages.isEmpty ? null : pages[currentIndex.clamp(0, pages.length - 1)];

  ScanSession copyWith({
    List<ScanPage>? pages,
    bool? autoEnhance,
    int? currentIndex,
  }) {
    return ScanSession(
      pages: pages ?? this.pages,
      autoEnhance: autoEnhance ?? this.autoEnhance,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

@immutable
class StudioDocument {
  const StudioDocument({
    required this.id,
    required this.name,
    required this.pdfPath,
    required this.pageCount,
    required this.sizeBytes,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    this.thumbnailPath,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String pdfPath;
  final String? thumbnailPath;
  final int pageCount;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DocumentSource source;
  final bool isFavorite;

  String get fileName => name.endsWith('.pdf') ? name : '$name.pdf';

  StudioDocument copyWith({
    String? name,
    String? pdfPath,
    String? thumbnailPath,
    int? pageCount,
    int? sizeBytes,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return StudioDocument(
      id: id,
      name: name ?? this.name,
      pdfPath: pdfPath ?? this.pdfPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pageCount: pageCount ?? this.pageCount,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pdfPath': pdfPath,
        'thumbnailPath': thumbnailPath,
        'pageCount': pageCount,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'source': source.name,
        'isFavorite': isFavorite,
      };

  factory StudioDocument.fromJson(Map<String, dynamic> json) {
    return StudioDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      pdfPath: json['pdfPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      pageCount: json['pageCount'] as int,
      sizeBytes: json['sizeBytes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      source: DocumentSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => DocumentSource.scan,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemePreference.dark,
    this.quality = ScanQuality.balanced,
    this.hasOnboarded = false,
    this.saveCount = 0,
  });

  final ThemePreference themeMode;
  final ScanQuality quality;
  final bool hasOnboarded;
  final int saveCount;

  AppSettings copyWith({
    ThemePreference? themeMode,
    ScanQuality? quality,
    bool? hasOnboarded,
    int? saveCount,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      quality: quality ?? this.quality,
      hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      saveCount: saveCount ?? this.saveCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'quality': quality.name,
        'hasOnboarded': hasOnboarded,
        'saveCount': saveCount,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemePreference.values.firstWhere(
        (value) => value.name == json['themeMode'],
        orElse: () => ThemePreference.dark,
      ),
      quality: ScanQuality.values.firstWhere(
        (value) => value.name == json['quality'],
        orElse: () => ScanQuality.balanced,
      ),
      hasOnboarded: json['hasOnboarded'] as bool? ?? false,
      saveCount: json['saveCount'] as int? ?? 0,
    );
  }
}

enum ThemePreference {
  light,
  dark;

  bool get isDark => this == ThemePreference.dark;
}

@immutable
class PendingPage {
  const PendingPage({
    required this.id,
    required this.path,
    this.label,
  });

  final String id;
  final String path;
  final String? label;
}
