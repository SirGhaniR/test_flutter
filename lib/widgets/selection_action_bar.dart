import 'package:flutter/material.dart';

class SelectionActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCopy;
  final VoidCallback onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const SelectionActionBar({
    super.key,
    required this.selectedCount,
    required this.onCopy,
    required this.onToggleDone,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Material(
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
          spacing: 4,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onCancel,
                tooltip: 'Cancel selection',
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$selectedCount selected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),

              const Spacer(),

              _ActionButton(
                icon: Icons.check_circle_outline,
                label: 'Done',
                onPressed: onToggleDone,
                isDark: isDark,
              ),

              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete',
                onPressed: onDelete,
                isDark: isDark,
                color: Colors.red,
              ),

              FilledButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_all, size: 18),
                label: const Text('Copy'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? (isDark ? Colors.grey.shade300 : Colors.grey.shade700);
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, color: effectiveColor),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
