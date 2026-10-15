import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/core/widgets/app_row.dart';
import 'package:waqt/core/widgets/app_search_field.dart';
import 'package:waqt/features/prayer_times/data/cities.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:waqt/features/prayer_times/services/location_service.dart';

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  String _query = '';
  String? _selectedCountry;
  bool _locating = false;

  // helper methods ke liye (build ka local `t` shadow karta hai)
  dynamic get t => ref.read(translationProvider);

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final query = _query.toLowerCase();
    final selectedCountry = _selectedCountry;

    // Filter cities by country first
    List<City> allFilteredCities;
    if (selectedCountry != null && selectedCountry != 'DEFAULT') {
      allFilteredCities = cities
          .where((city) => city.countryCode == selectedCountry)
          .toList();
    } else {
      allFilteredCities = cities;
    }

    // Then filter by search query
    final results = [
      for (final city in allFilteredCities)
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
              Text(t('choose_city'), style: AppText.title),
              AppSearchField(
                hint: t('search_city'),
                onChanged: (value) => setState(() => _query = value),
              ),
              // Country selector
              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
                dropdownColor: AppColors.background,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                items: countries.map((country) {
                  return DropdownMenuItem(
                    value: country.code,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() {
                  _selectedCountry = value;
                  _query = ''; // Clear search when country changes
                }),
              ),
              AppRow(
                label: t('use_location'),
                labelColor: AppColors.green,
                value: _locating ? '...' : null,
                onTap: _useCurrentLocation,
              ),
              Text(t('results'), style: AppText.label),
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

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    final city = await LocationService().detectCity();
    if (!mounted) return;
    setState(() => _locating = false);
    final tr = ref.read(translationProvider);
    if (city == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('location_failed'))));
      return;
    }
    ref.read(cityProvider.notifier).select(city);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr('location_auto_selected').replaceAll('{city}', city.name),
        ),
      ),
    );
    context.pop();
  }
}
