import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class DaySelector extends StatelessWidget {
  const DaySelector({
    super.key,
    required this.selectedDate,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _DayChip(
                label: AppFormatters.weekdayAbbreviation(day),
                dayNumber: day.day,
                selected: _isSameDay(day, selectedDate),
                onTap: () => onSelected(day),
              ),
            ),
          ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.dayNumber,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int dayNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? Colors.white70 : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
