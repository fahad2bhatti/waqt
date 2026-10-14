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

class CitySearchScreen extends ConsumerStatefulWidget {
  const CitySearchScreen({super.key});

  @override
  ConsumerState<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends ConsumerState<CitySearchScreen> {
  String _query = '';
  String? _selectedCountry;

  // helper methods ke liye (build ka local `t` shadow karta hai)
  get t => ref.read(translationProvider);

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);
    final query = _query.toLowerCase();
    final selectedCountry = _selectedCountry;
    
    // Filter cities by country first
    List<City> allFilteredCities;
    if (selectedCountry != null && selectedCountry != 'DEFAULT') {
      allFilteredCities = cities.where((city) => city.countryCode == selectedCountry).toList();
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
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
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
                onTap: () {
                  // Navigate to location detection screen or show location modal
                  _showLocationDetectionDialog();
                },
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
                        ref.read(selectedCityProvider.notifier).state = city;
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

  void _showLocationDetectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          t('detect_location'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          t('permission_explanation'),
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t('cancel'),
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
    
    // TODO: Implement actual location detection
    // This would call the location service to detect the user's position
    // and auto-select the closest city
  }
}