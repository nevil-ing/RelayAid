import 'package:flutter/material.dart';

import '../core/network/backend_configuration.dart';
import '../design_system/components/app_button.dart';
import '../design_system/components/relayaid_brand.dart';
import '../design_system/theme/app_theme.dart';
import '../design_system/tokens/app_spacing.dart';

class RelayAidStartup extends StatefulWidget {
  const RelayAidStartup({required this.initialize, super.key});
  final Future<Widget> Function() initialize;

  @override
  State<RelayAidStartup> createState() => _RelayAidStartupState();
}

class _RelayAidStartupState extends State<RelayAidStartup> {
  late Future<Widget> _startup;

  @override
  void initState() {
    super.initState();
    _startup = Future.sync(widget.initialize);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.hasData) return snapshot.data!;
      return MaterialApp(
        title: 'RelayAid',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.space24),
              children: [
                const RelayAidBrand(),
                const SizedBox(height: AppSpacing.space32),
                if (!snapshot.hasError)
                  const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Opening your saved workspace',
                    ),
                  )
                else ...[
                  const Text('RelayAid could not start.'),
                  const SizedBox(height: AppSpacing.space12),
                  Text(
                    snapshot.error is BackendConfigurationFailure
                        ? (snapshot.error! as BackendConfigurationFailure)
                              .message
                        : 'Your saved reports have not been erased. Close other copies of the app and try again. If this continues, contact the beta organizer.',
                  ),
                  const SizedBox(height: AppSpacing.space24),
                  AppButton(
                    label: 'Try again',
                    icon: Icons.refresh,
                    onPressed: () {
                      final nextAttempt = Future.sync(widget.initialize);
                      setState(() {
                        _startup = nextAttempt;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
