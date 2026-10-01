import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/app_search_field.dart';
import 'package:waqt/features/prayer_mode/data/available_apps.dart';
import 'package:waqt/features/prayer_mode/providers/blocked_apps_provider.dart';

class AppPickerScreen extends ConsumerStatefulWidget {
  const AppPickerScreen({super.key});

  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final blocked = ref.watch(blockedAppsProvider);
    final notifier = ref.read(blockedAppsProvider.notifier);
    final query = _query.toLowerCase();
    final apps = [
      for (final app in availableApps)
        if (app.toLowerCase().contains(query)) app,
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              const Text('Choose apps', style: AppText.title),
              AppSearchField(
                hint: 'Search apps',
                onChanged: (value) => setState(() => _query = value),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: apps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => AppRow(
                    label: apps[index],
                    trailing: Switch(
                      value: blocked.contains(apps[index]),
                      onChanged: (_) => notifier.toggle(apps[index]),
                    ),
                  ),
                ),
              ),
              const Text(
                'Phone, SMS and Maps are always allowed.',
                style: AppText.caption,
              ),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
