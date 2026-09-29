import 'package:flutter/material.dart';
import '../models/note_node.dart';

class WorkspaceNavigationDrawer extends StatefulWidget {
  final List<NoteNode> nodes;
  final NoteNode? selectedNode;
  final Function(NoteNode) onNodeSelected;
  final Function(String parentPath, bool isDirectory) onCreateNew;

  const WorkspaceNavigationDrawer({
    super.key,
    required this.nodes,
    required this.selectedNode,
    required this.onNodeSelected,
    required this.onCreateNew,
  });

  @override
  State<WorkspaceNavigationDrawer> createState() =>
      _WorkspaceNavigationDrawerState();
}

class _WorkspaceNavigationDrawerState
    extends State<WorkspaceNavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header with title & action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Workspace',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      // Create file at root
                      IconButton(
                        icon: const Icon(Icons.note_add_outlined, size: 20),
                        tooltip: 'New Note',
                        onPressed: () => widget.onCreateNew('', false),
                      ),
                      // Create folder at root
                      IconButton(
                        icon: const Icon(Icons.create_new_folder_outlined, size: 20),
                        tooltip: 'New Folder',
                        onPressed: () => widget.onCreateNew('', true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tree View List
            Expanded(
              child: widget.nodes.isEmpty
                  ? const Center(
                      child: Text(
                        'No markdown files found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: widget.nodes
                          .map((node) => _buildNodeTile(node, depth: 0))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recursive widget builder for tree items
  Widget _buildNodeTile(NoteNode node, {required int depth}) {
    final bool isSelected = widget.selectedNode?.path == node.path;
    final double indentPadding = (depth * 16.0) + 12.0;

    if (node.isDirectory) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(left: indentPadding, right: 8),
            dense: true,
            leading: Icon(
              node.isExpanded
                  ? Icons.folder_open_rounded
                  : Icons.folder_rounded,
              color: Colors.amber[700],
              size: 20,
            ),
            title: Text(
              node.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  tooltip: 'Add note here',
                  onPressed: () => widget.onCreateNew(node.path, false),
                ),
                Icon(
                  node.isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 18,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                node.isExpanded = !node.isExpanded;
              });
            },
          ),
          
          // Render children recursively if expanded
          if (node.isExpanded && node.children.isNotEmpty)
            ...node.children.map(
              (child) => _buildNodeTile(child, depth: depth + 1),
            ),
        ],
      );
    } else {
      // File Tile
      return ListTile(
        contentPadding: EdgeInsets.only(left: indentPadding, right: 8),
        dense: true,
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        leading: const Icon(
          Icons.description_outlined,
          color: Colors.blueAccent,
          size: 20,
        ),
        title: Text(
          node.name,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => widget.onNodeSelected(node),
      );
    }
  }
}