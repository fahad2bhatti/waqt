import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/app_search_field.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.toLowerCase();
    final results = [
      for (final city in cities)
        if (city.name.toLowerCase().contains(query) ||
            city.country.toLowerCase().contains(query))
          city,
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
              const Text('Choose city', style: AppText.title),
              AppSearchField(
                hint: 'Search city',
                onChanged: (value) => setState(() => _query = value),
              ),
              const AppRow(
                label: 'Use current location',
                labelColor: AppColors.green,
              ),
              const Text('RESULTS', style: AppText.label),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final city = results[index];
                    return AppRow(
                      label: '${city.name}, ${city.country}',
                      value: city.timezone,
                      onTap: () {
                        ref.read(cityProvider.notifier).select(city);
                        context.pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
