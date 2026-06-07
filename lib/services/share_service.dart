import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a widget (the share card) to a PNG and hands it to the OS share
/// sheet — Instagram, Facebook, Messages, etc.
class ShareService {
  ShareService._();
  static final ShareService instance = ShareService._();

  /// Rasterises the [RepaintBoundary] behind [key] to PNG bytes.
  Future<Uint8List?> capture(GlobalKey key, {double pixelRatio = 3}) async {
    final context = key.currentContext;
    if (context == null) return null;
    final boundary = context.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  /// Captures the card and opens the native share sheet with an image + caption.
  Future<bool> shareCard(
    GlobalKey key, {
    required String caption,
    double pixelRatio = 3,
  }) async {
    final bytes = await capture(key, pixelRatio: pixelRatio);
    if (bytes == null) return false;
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/money_bird_health_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: caption,
      ),
    );
    return true;
  }
}
