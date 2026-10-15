import 'package:waqt/core/storage/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/core/utils/translations.dart';
import 'package:waqt/features/prayer_times/data/countries.dart';
import 'package:waqt/features/prayer_times/providers/city_provider.dart';
import 'package:go_router/go_router.dart';

class CountrySelectionScreen extends ConsumerStatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  ConsumerState<CountrySelectionScreen> createState() =>
      _CountrySelectionScreenState();
}

class _CountrySelectionScreenState
    extends ConsumerState<CountrySelectionScreen> {
  String _selectedCountryCode = '';

  final List<String> _sortOrder = [
    'PK',
    'SA',
    'AE',
    'QA',
    'KW',
    'BH',
    'OM',
    'IL',
    'IN',
    'BD',
    'NP',
    'LK',
    'MV',
    'SG',
    'MY',
    'ID',
    'PH',
    'TH',
    'TR',
    'EG',
    'MA',
    'TN',
    'KE',
    'GB',
    'DE',
    'FR',
    'IT',
    'ES',
    'NL',
    'SE',
    'NO',
    'DK',
    'FI',
    'PL',
    'AT',
    'CH',
    'IE',
    'US',
    'CA',
    'BR',
    'MX',
    'AR',
  ];

  @override
  void initState() {
    super.initState();
    // Default to Pakistan
    _selectedCountryCode = 'PK';
  }

  void _applySelection() {
    if (_selectedCountryCode.isEmpty) return;

    final city = getCityForPlayStoreCountry(_selectedCountryCode);
    if (city != null) {
      // Set city and country
      ref.read(cityProvider.notifier).select(city);
      ref.read(selectedCountryProvider.notifier).state = countryByCode(
        _selectedCountryCode,
      );
      ref.read(prefsProvider).setString('last_country', _selectedCountryCode);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated to ${city.name}, ${city.country}')),
      );

      // Go back
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationProvider);

    // Sort countries by preference order
    final sortedCountries = [...countries];
    sortedCountries.sort((a, b) {
      final aIndex = _sortOrder.indexOf(a.code);
      final bIndex = _sortOrder.indexOf(b.code);
      final aPos = aIndex == -1 ? _sortOrder.length : aIndex;
      final bPos = bIndex == -1 ? _sortOrder.length : bIndex;
      return aPos.compareTo(bPos);
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Text(t('country_section'), style: AppText.title),
              Text(
                'Select your country for appropriate prayer time defaults. '
                'The app will use the default city for that country and adjust calculation methods.',
                style: AppText.body.copyWith(color: AppColors.textMuted),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCountryCode.isEmpty
                    ? null
                    : _selectedCountryCode,
                decoration: InputDecoration(
                  labelText: t('play_store_country'),
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                ),
                dropdownColor: AppColors.background,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                items: sortedCountries.where((c) => c.code != 'DEFAULT').map((
                  country,
                ) {
                  return DropdownMenuItem(
                    value: country.code,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCountryCode = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.hero.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      'Default For Selected Country:',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _getCountryDefaultInfo(),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calculation method and Asr will be set to regional defaults.',
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _selectedCountryCode.isEmpty
                    ? null
                    : _applySelection,
                icon: const Icon(Icons.check),
                label: Text(t('apply')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountryDefaultInfo() {
    if (_selectedCountryCode.isEmpty) return 'None selected';

    final city = getCityForPlayStoreCountry(_selectedCountryCode);
    if (city == null) return 'No default city';

    return '${city.name}, ${city.country}';
  }
}
