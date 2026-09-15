import 'package:flutter/material.dart';

class TodoStats extends StatelessWidget {
  final int total;
  final int left;
  final bool isDark;

  const TodoStats({
    super.key,
    required this.total,
    required this.left,
    required this.isDark,
  });

  Color get accentColor {
    if (progress == 1.0 && total > 0) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.25) return Colors.orange;
    return Colors.red;
  }

  int get done => total - left;

  double get progress {
    if (total == 0) return 0;
    return done / total;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
        ),
        child: Column(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
            Row(
              children: [
                Text(
                  '$done of $total done',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Text(
                  left == 0 ? 'All caught up!' : '$left left',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: left == 0
                        ? Colors.green
                        : (isDark ? Colors.indigoAccent : Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
