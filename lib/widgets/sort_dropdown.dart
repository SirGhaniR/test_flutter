import 'package:flutter/material.dart';

class SortDropdown extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<SortOption>(
        value: currentSort,
        underline: const SizedBox(),
        icon: Icon(
          Icons.sort,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
        dropdownColor: isDark ? Colors.grey[850] : Colors.white,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
        items: const [
          DropdownMenuItem(
            value: SortOption.newest,
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.access_time, size: 16),
                Text('Newest First'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: SortOption.oldest,
            child: Row(
              spacing: 8,
              children: [Icon(Icons.history, size: 16), Text('Oldest First')],
            ),
          ),
          DropdownMenuItem(
            value: SortOption.priorityHigh,
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                Text('Priority: High → Low'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: SortOption.priorityLow,
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                Text('Priority: Low → High'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: SortOption.alphabetical,
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.sort_by_alpha, size: 16),
                Text('Alphabetical'),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onSortChanged(value);
          }
        },
      ),
    );
  }
}

enum SortOption { newest, oldest, priorityHigh, priorityLow, alphabetical }
