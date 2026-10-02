import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';
import 'package:waqt/app/theme/app_text.dart';
import 'package:waqt/features/tracking/providers/streak_provider.dart';

class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.today,
    required this.log,
  });

  /// Any date inside the month to show.
  final DateTime month;

  /// Today, as a date-only value.
  final DateTime today;
  final Set<String> log;

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final blanks = first.weekday - 1;

    return Column(
      spacing: 12,
      children: [
        Row(
          children: [
            for (final letter in _letters)
              Expanded(
                child: Center(child: Text(letter, style: AppText.caption)),
              ),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              _DayCell(
                day: DateTime(month.year, month.month, d),
                today: today,
                count: prayersLoggedOn(
                  log,
                  DateTime(month.year, month.month, d),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.today, required this.count});

  final DateTime day;
  final DateTime today;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isFuture = day.isAfter(today);
    final (Color fill, Color text) = isFuture
        ? (Colors.transparent, AppColors.textMuted.withValues(alpha: 0.5))
        : count == dailyPrayers.length
        ? (AppColors.green, Colors.white)
        : count > 0
        ? (AppColors.gold, AppColors.background)
        : (AppColors.line, AppColors.textMuted);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: day == today
            ? Border.all(color: AppColors.textPrimary, width: 2)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}
