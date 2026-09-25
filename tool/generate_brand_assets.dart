import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders Aajhee Business brand assets using bundled Inter 800.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fontData = await rootBundle.load('assets/fonts/Inter-800.ttf');
  final loader = FontLoader('Inter')..addFont(Future.value(fontData));
  await loader.load();

  const brandColor = Color(0xFF1F1F21);
  const white = Color(0xFFFFFFFF);

  await _renderStackedWordmark(
    outputPath: 'assets/images/aajhee_business_logo.png',
    topText: 'Go',
    bottomText: 'Business',
    topFontSize: 280,
    bottomFontSize: 120,
    color: brandColor,
    width: 2400,
    height: 1200,
    transparentBackground: true,
  );

  await _renderAppIcon(
    outputPath: 'assets/images/app_icon_source.png',
    size: 1024,
    topText: 'Go',
    bottomText: 'Business',
    foreground: brandColor,
    background: white,
  );

  await _renderAppIconForeground(
    outputPath: 'assets/images/app_icon_foreground.png',
    size: 1024,
    topText: 'Go',
    bottomText: 'Business',
    foreground: brandColor,
  );

  stdout.writeln('Business brand assets generated successfully.');
}

Future<void> _renderStackedWordmark({
  required String outputPath,
  required String topText,
  required String bottomText,
  required double topFontSize,
  required double bottomFontSize,
  required Color color,
  required int width,
  required int height,
  required bool transparentBackground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (!transparentBackground) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Colors.white,
    );
  }

  final topPainter = _buildTextPainter(
    topText,
    topFontSize,
    color,
  )..layout();

  final bottomPainter = _buildTextPainter(
    bottomText,
    bottomFontSize,
    color,
  )..layout();

  const gap = 24.0;
  final totalHeight = topPainter.height + gap + bottomPainter.height;
  final topY = (height - totalHeight) / 2;

  topPainter.paint(
    canvas,
    Offset((width - topPainter.width) / 2, topY),
  );

  bottomPainter.paint(
    canvas,
    Offset((width - bottomPainter.width) / 2, topY + topPainter.height + gap),
  );

  await _savePng(recorder, width, height, outputPath);
}

Future<void> _renderAppIcon({
  required String outputPath,
  required int size,
  required String topText,
  required String bottomText,
  required Color foreground,
  required Color background,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();
  const radius = 224.0;

  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, s, s),
    Radius.circular(radius * (s / 1024)),
  );
  canvas.drawRRect(rrect, Paint()..color = background);

  _paintStackedText(
    canvas: canvas,
    size: s,
    topText: topText,
    bottomText: bottomText,
    foreground: foreground,
    topScale: 0.34,
    bottomScale: 0.13,
    gapScale: 0.02,
  );

  await _savePng(recorder, size, size, outputPath);
}

Future<void> _renderAppIconForeground({
  required String outputPath,
  required int size,
  required String topText,
  required String bottomText,
  required Color foreground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();

  _paintStackedText(
    canvas: canvas,
    size: s,
    topText: topText,
    bottomText: bottomText,
    foreground: foreground,
    topScale: 0.34,
    bottomScale: 0.13,
    gapScale: 0.02,
  );

  await _savePng(recorder, size, size, outputPath);
}

void _paintStackedText({
  required Canvas canvas,
  required double size,
  required String topText,
  required String bottomText,
  required Color foreground,
  required double topScale,
  required double bottomScale,
  required double gapScale,
}) {
  final topFontSize = size * topScale;
  final bottomFontSize = size * bottomScale;
  final gap = size * gapScale;

  final topPainter = _buildTextPainter(topText, topFontSize, foreground)
    ..layout();
  final bottomPainter = _buildTextPainter(bottomText, bottomFontSize, foreground)
    ..layout();

  final totalHeight = topPainter.height + gap + bottomPainter.height;
  final topY = (size - totalHeight) / 2 - size * 0.01;

  topPainter.paint(
    canvas,
    Offset((size - topPainter.width) / 2, topY),
  );

  bottomPainter.paint(
    canvas,
    Offset((size - bottomPainter.width) / 2, topY + topPainter.height + gap),
  );
}

TextPainter _buildTextPainter(String text, double fontSize, Color color) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: fontSize * -0.009,
        height: 1,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
}

Future<void> _savePng(
  ui.PictureRecorder recorder,
  int width,
  int height,
  String outputPath,
) async {
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Failed to encode PNG for $outputPath');
  }
  await File(outputPath).writeAsBytes(byteData.buffer.asUint8List());
  stdout.writeln('Wrote $outputPath (${width}x$height)');
}
