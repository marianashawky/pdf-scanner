class AppConstants {
  const AppConstants._();

  static const appName = 'PDF Scanner';
  static const studioName = 'Document studio';
  static const versionLabel = 'Private document studio · v1.0';

  static const androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const iosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static const interstitialEvery = 3;
}

enum ScanQuality {
  compact,
  balanced,
  high;

  String get label => switch (this) {
        ScanQuality.compact => 'Compact',
        ScanQuality.balanced => 'Balanced',
        ScanQuality.high => 'High',
      };

  String get subtitle => switch (this) {
        ScanQuality.compact => 'Smaller files, faster sharing',
        ScanQuality.balanced => 'Best everyday studio quality',
        ScanQuality.high => 'Maximum clarity for archives',
      };

  int get maxWidth => switch (this) {
        ScanQuality.compact => 1200,
        ScanQuality.balanced => 1800,
        ScanQuality.high => 2400,
      };

  int get jpegQuality => switch (this) {
        ScanQuality.compact => 70,
        ScanQuality.balanced => 84,
        ScanQuality.high => 92,
      };
}

enum ScanFilter {
  original,
  color,
  grayscale,
  blackWhite;

  String get label => switch (this) {
        ScanFilter.original => 'Original',
        ScanFilter.color => 'Color',
        ScanFilter.grayscale => 'Grayscale',
        ScanFilter.blackWhite => 'B&W',
      };
}

enum DocumentSource {
  scan,
  images,
  merge,
  split,
  compress,
  import;

  String get label => switch (this) {
        DocumentSource.scan => 'Scan',
        DocumentSource.images => 'Images',
        DocumentSource.merge => 'Merged',
        DocumentSource.split => 'Split',
        DocumentSource.compress => 'Compressed',
        DocumentSource.import => 'Imported',
      };
}
