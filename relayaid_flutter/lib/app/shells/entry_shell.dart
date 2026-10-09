import 'package:flutter/material.dart';

import '../../design_system/tokens/app_breakpoints.dart';

class EntryShell extends StatelessWidget {
  const EntryShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RelayAid')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.commandCenter,
          ),
          child: child,
        ),
      ),
    );
  }
}
