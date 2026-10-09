import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_client/relayaid_client.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_provider.dart';
import 'package:relayaid_flutter/core/connectivity/connectivity_status.dart';
import 'package:relayaid_flutter/features/media/application/media_providers.dart';
import 'package:relayaid_flutter/features/media/domain/attachment_repository.dart';
import 'package:relayaid_flutter/features/media/presentation/photo_draft_section.dart';
import 'package:relayaid_flutter/features/media/presentation/attachment_queue_section.dart';
import 'support/media_fixture.dart';

void main() {
  Future<MediaFixture> fixtureWithPhoto({
    bool providerOwnsConnectivity = false,
  }) async {
    final fixture = MediaFixture();
    addTearDown(
      () => fixture.dispose(ownsConnectivity: !providerOwnsConnectivity),
    );
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(const Color(0xff808080), BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(2, 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    fixture.picker.bytes = png!.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    return fixture;
  }

  testWidgets(
    'offline draft photo can be previewed and removed at phone width',
    (tester) async {
      final fixture = (await tester.runAsync(() => fixtureWithPhoto()))!;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attachmentRepositoryProvider.overrideWithValue(fixture.attachments),
            photoPickerProvider.overrideWithValue(fixture.picker),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(24),
                child: PhotoDraftSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose photo'));
      await tester.pumpAndSettle();
      expect(find.text('Saved with this report'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.text('Close photo'), findsOneWidget);
      await tester.tap(find.text('Close photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove photo'));
      await tester.pumpAndSettle();
      expect(find.text('Saved with this report'), findsNothing);
    },
  );

  testWidgets(
    'failed upload has an explicit retry action and clears after retry',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => fixtureWithPhoto(providerOwnsConnectivity: true),
      ))!;
      final id = Uuid().v7obj();
      await fixture.attachments.capture(id, PhotoSource.library);
      await fixture.report(id);
      fixture.remote.failures = 1;
      fixture.connectivity.setStatusForTest(ConnectivityStatus.connected);
      await fixture.attachments.process();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            attachmentRepositoryProvider.overrideWithValue(fixture.attachments),
            connectivityControllerProvider.overrideWith(
              (ref) => fixture.connectivity,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: AttachmentQueueSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Upload failed · retry available'), findsOneWidget);
      await tester.tap(find.text('Retry uploads now'));
      await tester.pumpAndSettle();
      expect(find.text('No photos waiting to upload.'), findsOneWidget);
      // This fixture's ChangeNotifier is owned by the overridden provider.
    },
  );
}
