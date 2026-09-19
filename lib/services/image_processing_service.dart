import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../data/models.dart';

class ImageProcessingService {
  static const _uuid = Uuid();

  Future<img.Image> decode(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Could not read that image.');
    }
    return img.bakeOrientation(decoded);
  }

  QuadCorners detectDocument(img.Image source) {
    final work = img.copyResize(
      source,
      width: 220,
      interpolation: img.Interpolation.average,
    );
    img.grayscale(work);
    img.gaussianBlur(work, radius: 1);

    final threshold = _otsu(work);
    var minX = work.width;
    var minY = work.height;
    var maxX = 0;
    var maxY = 0;
    var hits = 0;

    for (var y = 0; y < work.height; y++) {
      for (var x = 0; x < work.width; x++) {
        final pixel = work.getPixel(x, y);
        if (pixel.luminance > threshold) {
          hits++;
          minX = math.min(minX, x);
          minY = math.min(minY, y);
          maxX = math.max(maxX, x);
          maxY = math.max(maxY, y);
        }
      }
    }

    final coverage = hits / (work.width * work.height);
    if (coverage < 0.08 || maxX <= minX || maxY <= minY) {
      return QuadCorners.full;
    }

    const pad = 0.012;
    return QuadCorners(
      topLeft: OffsetNorm(minX / work.width - pad, minY / work.height - pad).clamp(),
      topRight: OffsetNorm(maxX / work.width + pad, minY / work.height - pad).clamp(),
      bottomRight: OffsetNorm(maxX / work.width + pad, maxY / work.height + pad).clamp(),
      bottomLeft: OffsetNorm(minX / work.width - pad, maxY / work.height + pad).clamp(),
    );
  }

  Future<Uint8List> processPage({
    required String sourcePath,
    required QuadCorners corners,
    required int rotation,
    required ScanFilter filter,
    required ScanQuality quality,
    required bool enhance,
  }) async {
    var image = await decode(sourcePath);
    image = _perspectiveCrop(image, corners);
    if (rotation % 360 != 0) {
      image = img.copyRotate(image, angle: rotation.toDouble());
    }
    image = _fitQuality(image, quality);
    image = _applyFilter(image, filter, enhance);
    return Uint8List.fromList(img.encodeJpg(image, quality: quality.jpegQuality));
  }

  Future<String> writeProcessed({
    required Uint8List bytes,
    required Directory directory,
    String? name,
  }) async {
    final file = File(p.join(directory.path, '${name ?? _uuid.v4()}.jpg'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  img.Image _fitQuality(img.Image image, ScanQuality quality) {
    if (image.width <= quality.maxWidth) return image;
    return img.copyResize(
      image,
      width: quality.maxWidth,
      interpolation: img.Interpolation.cubic,
    );
  }

  img.Image _applyFilter(img.Image image, ScanFilter filter, bool enhance) {
    switch (filter) {
      case ScanFilter.original:
        return enhance ? _enhanceColor(image) : image;
      case ScanFilter.color:
        return _enhanceColor(image);
      case ScanFilter.grayscale:
        return img.grayscale(image);
      case ScanFilter.blackWhite:
        final gray = img.grayscale(image);
        final threshold = _otsu(gray);
        for (final pixel in gray) {
          final value = pixel.luminance >= threshold ? 255 : 0;
          pixel
            ..r = value
            ..g = value
            ..b = value;
        }
        return gray;
    }
  }

  img.Image _enhanceColor(img.Image image) {
    img.adjustColor(
      image,
      contrast: 1.12,
      saturation: 1.08,
      brightness: 1.03,
    );
    return image;
  }

  img.Image _perspectiveCrop(img.Image source, QuadCorners corners) {
    final tl = _toPixel(source, corners.topLeft);
    final tr = _toPixel(source, corners.topRight);
    final br = _toPixel(source, corners.bottomRight);
    final bl = _toPixel(source, corners.bottomLeft);

    final width = math.max(_distance(tl, tr), _distance(bl, br)).round().clamp(80, 4000);
    final height = math.max(_distance(tl, bl), _distance(tr, br)).round().clamp(80, 4000);
    final dest = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      final v = height == 1 ? 0.0 : y / (height - 1);
      for (var x = 0; x < width; x++) {
        final u = width == 1 ? 0.0 : x / (width - 1);
        final top = _lerp(tl, tr, u);
        final bottom = _lerp(bl, br, u);
        final sample = _lerp(top, bottom, v);
        dest.setPixel(
          x,
          y,
          source.getPixel(
            sample.x.round().clamp(0, source.width - 1),
            sample.y.round().clamp(0, source.height - 1),
          ),
        );
      }
    }
    return dest;
  }

  math.Point<double> _toPixel(img.Image source, OffsetNorm offset) {
    return math.Point(offset.dx * (source.width - 1), offset.dy * (source.height - 1));
  }

  math.Point<double> _lerp(math.Point<double> a, math.Point<double> b, double t) {
    return math.Point(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
  }

  double _distance(math.Point<double> a, math.Point<double> b) {
    return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2));
  }

  int _otsu(img.Image gray) {
    final histogram = List<int>.filled(256, 0);
    for (final pixel in gray) {
      histogram[pixel.luminance.round().clamp(0, 255)]++;
    }
    final total = gray.width * gray.height;
    var sum = 0;
    for (var i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }
    var sumB = 0;
    var wB = 0;
    var max = 0.0;
    var threshold = 180;
    for (var i = 0; i < 256; i++) {
      wB += histogram[i];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;
      sumB += i * histogram[i];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB * wF * math.pow(mB - mF, 2);
      if (between > max) {
        max = between.toDouble();
        threshold = i;
      }
    }
    return threshold;
  }
}
