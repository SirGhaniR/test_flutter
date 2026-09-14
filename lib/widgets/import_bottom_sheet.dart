import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/todo_importer.dart';
import '../models/todo.dart';

class ImportBottomSheet extends StatefulWidget {
  final void Function(List<Todo> todos) onImport;

  const ImportBottomSheet({super.key, required this.onImport});

  @override
  State<ImportBottomSheet> createState() => _ImportBottomSheetState();
}

class _ImportBottomSheetState extends State<ImportBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  ImportResult? _preview;
  bool _showingPreview = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.download, color: accent),
                    Expanded(
                      child: Column(
                        spacing: 2,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Import Tasks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            "Paste JSON or Markdown below",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                OutlinedButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste, size: 18),
                  label: const Text("Paste From Clipboard"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: '[\n  {\n    "title": "Buy groceries",\n    "description": "Milk, eggs",\n    "priority": "high"\n  }\n]',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (_) {
                      if (_showingPreview) {
                        setState(() {
                          _preview = null;
                          _showingPreview = false;
                        });
                      }
                    },
                  ),
                ),

                if (_showingPreview && _preview != null) _buildPreview(isDark),

                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _showingPreview && _preview?.isSuccess == true
                          ? FilledButton.icon(
                              onPressed: _confirmImport,
                              icon: const Icon(Icons.check, size: 18),
                              label: Text('Import ${_preview!.todos.length}'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: _controller.text.trim().isEmpty
                                  ? null
                                  : _previewImport,
                              icon: const Icon(Icons.preview, size: 18),
                              label: const Text('Preview'),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPreview(bool isDark) {
    final result = _preview!;

    if (!result.isSuccess) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            Expanded(
              child: Text(
                result.error ?? 'Unknown error',
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              Expanded(
                child: Text(
                  'Detected ${result.format} · ${result.todos.length} task${result.todos.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ...result.todos
              .take(3)
              .map(
                (todo) => Row(
                  spacing: 6,
                  children: [
                    Icon(
                      todo.isDone
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 14,
                      color: Todo.getPriorityColor(todo.priority),
                    ),
                    Expanded(
                      child: Text(
                        todo.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Todo.getPriorityColor(todo.priority)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        todo.priority.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Todo.getPriorityColor(todo.priority),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (result.todos.length > 3)
            Text(
              '+ ${result.todos.length - 3} more...',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmImport() {
    if (_preview?.isSuccess == true) {
      widget.onImport(_preview!.todos);
      Navigator.pop(context);
      _showSnack(
        "Imported ${_preview!.todos.length} task${_preview!.todos.length > 1 ? 's' : ''}",
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _controller.text = data.text!;
        _preview = null;
        _showingPreview = false;
      });
    } else {
      _showSnack("Clipboard is empty");
    }
  }

  void _previewImport() {
    final result = TodoImporter.parse(_controller.text);
    setState(() {
      _preview = result;
      _showingPreview = true;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
