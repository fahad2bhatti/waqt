import 'package:adhan_dart/adhan_dart.dart';

enum CalcMethod {
  karachi('Karachi', 'University of Islamic Sciences, Karachi'),
  muslimWorldLeague('Muslim World League', 'Fajr 18°, Isha 17°'),
  egyptian('Egyptian', 'Egyptian General Authority of Survey'),
  ummAlQura('Umm al-Qura', 'Makkah, Saudi Arabia'),
  northAmerica('ISNA', 'Islamic Society of North America'),
  moonsightingCommittee(
    'Moonsighting Committee',
    'Moonsighting Committee Worldwide',
  );

  const CalcMethod(this.label, this.note);

  final String label;
  final String note;

  CalculationParameters parameters() => switch (this) {
    CalcMethod.karachi => CalculationMethodParameters.karachi(),
    CalcMethod.muslimWorldLeague =>
      CalculationMethodParameters.muslimWorldLeague(),
    CalcMethod.egyptian => CalculationMethodParameters.egyptian(),
    CalcMethod.ummAlQura => CalculationMethodParameters.ummAlQura(),
    CalcMethod.northAmerica => CalculationMethodParameters.northAmerica(),
    CalcMethod.moonsightingCommittee =>
      CalculationMethodParameters.moonsightingCommittee(),
  };
}

String asrLabel(Madhab madhab) => madhab == Madhab.hanafi ? 'Hanafi' : 'Shafi';
