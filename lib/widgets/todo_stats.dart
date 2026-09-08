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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: $total tasks',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : null,
              ),
            ),
            Text(
              'Left: $left',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.indigoAccent : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
