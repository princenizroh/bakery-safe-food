import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Generate main icon
  await generateIcon(
    icon: Icons.bakery_dining,
    filename: 'app_icon.png',
    size: 1024.0,
    backgroundColor: Colors.white,
    iconColor: Color(0xFFFE7A36),
  );
  
  // Generate foreground for adaptive icon
  await generateIcon(
    icon: Icons.bakery_dining,
    filename: 'app_icon_foreground.png',
    size: 1024.0,
    backgroundColor: Colors.transparent,
    iconColor: Colors.white,
  );
  
  print('✅ Icons generated successfully!');
  print('Run: flutter pub run flutter_launcher_icons');
  exit(0);
}

Future<void> generateIcon({
  required IconData icon,
  required String filename,
  required double size,
  required Color backgroundColor,
  required Color iconColor,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw background
  final bgPaint = Paint()..color = backgroundColor;
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), bgPaint);
  
  // Draw icon
  final textPainter = TextPainter(textDirection: TextDirection.ltr);
  textPainter.text = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(
      fontSize: size * 0.6,
      fontFamily: icon.fontFamily,
      color: iconColor,
    ),
  );
  textPainter.layout();
  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );
  
  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();
  
  // Save to file
  final file = File('assets/icon/$filename');
  await file.writeAsBytes(buffer);
  
  print('✅ Generated: $filename');
}
