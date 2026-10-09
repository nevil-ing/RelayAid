import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relayaid_flutter/design_system/components/app_state_view.dart';
import 'package:relayaid_flutter/design_system/components/app_status_badge.dart';
import 'package:relayaid_flutter/design_system/components/app_text_field.dart';
import 'package:relayaid_flutter/design_system/theme/app_theme.dart';

void main() {
  testWidgets('status and state components expose their meaning as text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(
            children: <Widget>[
              AppStatusBadge(
                label: 'Offline',
                tone: AppStatusTone.warning,
                icon: Icons.cloud_off_outlined,
              ),
              AppStateView(
                state: AppViewState.error,
                title: 'Upload failed',
                description: 'Try again when a connection is available.',
              ),
              AppTextField(label: 'Location'),
            ],
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Current status: Offline'), findsOneWidget);
    expect(find.text('Upload failed'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
  });
}
