import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_flutter/design_system/components/relayaid_brand.dart';
import 'package:relayaid_flutter/design_system/tokens/app_colors.dart';

Future<List<int>> renderBrand(int size, {bool launch = false}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final inset = size * .22;
  if (!launch) canvas.drawColor(AppColors.primary, BlendMode.src);
  canvas.translate(inset, inset);
  RelayAidMarkPainter(
    launch ? AppColors.primary : AppColors.onPrimary,
  ).paint(canvas, Size.square(size - inset * 2));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'RelayAid vector brand renders to a PNG without external assets',
    () async {
      final bytes = await renderBrand(128);
      expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    },
  );

  if (const bool.fromEnvironment('RELAYAID_GENERATE_BRAND_ASSETS')) {
    test('generate platform icon and launch assets from the same vector', () async {
      final outputs = <String, int>{
        '../.github/assets/relayaid-icon.png': 1024,
        'web/favicon.png': 32,
        'web/icons/Icon-192.png': 192,
        'web/icons/Icon-512.png': 512,
        'web/icons/Icon-maskable-192.png': 192,
        'web/icons/Icon-maskable-512.png': 512,
      };
      final catalog =
          jsonDecode(
                await File(
                  'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
                ).readAsString(),
              )
              as Map<String, dynamic>;
      for (final entry in catalog['images'] as List<dynamic>) {
        final name = entry['filename'] as String?;
        if (name == null) continue;
        final points = double.parse((entry['size'] as String).split('x').first);
        final scale = int.parse((entry['scale'] as String).replaceAll('x', ''));
        outputs['ios/Runner/Assets.xcassets/AppIcon.appiconset/$name'] =
            (points * scale).round();
      }
      for (final entry in {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      }.entries) {
        outputs['android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png'] =
            entry.value;
      }
      for (final entry in outputs.entries) {
        final file = File(entry.key);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(await renderBrand(entry.value));
      }
      for (final entry in {
        'LaunchImage.png': 168,
        'LaunchImage@2x.png': 336,
        'LaunchImage@3x.png': 504,
      }.entries) {
        await File(
          'ios/Runner/Assets.xcassets/LaunchImage.imageset/${entry.key}',
        ).writeAsBytes(await renderBrand(entry.value, launch: true));
      }
    });
  }
}
