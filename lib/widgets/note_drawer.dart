import 'package:flutter/material.dart';
import '../services/asset_loader.dart';

class NoteDrawer extends StatelessWidget {
  final List<NoteNode> nodes;
  final String? selectedNotePath;
  final ValueChanged<String> onNoteSelected;

  const NoteDrawer({
    super.key,
    required this.nodes,
    required this.selectedNotePath,
    required this.onNoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Drawer(
        width: 280,
        child: SafeArea(
          child: nodes.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  children: nodes
                      .map((node) => _buildNodeTile(context, node))
                      .toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildNodeTile(BuildContext context, NoteNode node) {
    if (node.isDirectory) {
      return ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const Border(),
        title: Text(
          node.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 12.0),
        children: node.children
            .map((child) => _buildNodeTile(context, child))
            .toList(),
      );
    } else {
      final isSelected = node.path == selectedNotePath;
      final theme = Theme.of(context);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        child: Material(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
            title: Text(
              node.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
            onTap: () => onNoteSelected(node.path),
          ),
        ),
      );
    }
  }
}