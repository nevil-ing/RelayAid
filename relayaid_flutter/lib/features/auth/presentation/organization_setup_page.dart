import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../shared/presentation/member_id_view.dart';
import '../application/access_controller.dart';

class OrganizationSetupPage extends ConsumerStatefulWidget {
  const OrganizationSetupPage({super.key});

  @override
  ConsumerState<OrganizationSetupPage> createState() =>
      _OrganizationSetupPageState();
}

class _OrganizationSetupPageState extends ConsumerState<OrganizationSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(accessControllerProvider).createOrganization(_name.text);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Organization setup failed. Try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set up your organization',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.space8),
                Text(
                  'Create the workspace your response team will use. You will be its administrator.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.space16),
                const Text(
                  'Joining an existing team? Send your user ID to its administrator:',
                ),
                MemberIdView(
                  userId: ref
                      .watch(accessControllerProvider)
                      .userId
                      ?.toString(),
                ),
                const SizedBox(height: AppSpacing.space32),
                TextFormField(
                  controller: _name,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Organization name',
                  ),
                  validator: (value) => (value?.trim().length ?? 0) < 3
                      ? 'Enter at least 3 characters.'
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.space16),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.space24),
                AppButton(
                  label: _submitting ? 'Creating…' : 'Create organization',
                  onPressed: _submitting ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.space16),
                TextButton(
                  onPressed: () => ref.read(accessControllerProvider).refresh(),
                  child: const Text('I have been added — check access'),
                ),
                TextButton(
                  onPressed: () => ref.read(accessControllerProvider).signOut(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
