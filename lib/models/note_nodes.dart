import 'dart:io';

class NoteNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<NoteNode> children;
  bool isExpanded;

  NoteNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    List<NoteNode>? children,
    this.isExpanded = false,
  }) : children = children ?? [];

  /// Helper getter to quickly check if node is a Markdown file
  bool get isMarkdown => !isDirectory && path.endsWith('.md');
}