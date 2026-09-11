import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/todo_exporter.dart';
import '../models/todo.dart';

class ExportBottomSheet extends StatelessWidget {
  final List<Todo> todos;

  const ExportBottomSheet({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = todos.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              'Copy $count task${count > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'Choose a format to copy to clipboard',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),

            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.withValues(alpha: 0.2),
                child: const Icon(Icons.data_object, color: Colors.amber),
              ),
              title: const Text('Copy as JSON'),
              subtitle: const Text(
                'Structured data - perfect for backup & import',
              ),
              onTap: () => _copy(context, TodoExporter.toJson(todos), 'JSON'),
            ),

            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                child: const Icon(Icons.notes, color: Colors.blue),
              ),
              title: const Text('Copy as Markdown'),
              subtitle: const Text('Readable task list - great for sharing'),
              onTap: () =>
                  _copy(context, TodoExporter.toMarkdown(todos), 'Markdown'),
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text, String formatName) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $formatName to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
