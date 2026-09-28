import 'dart:convert';
import 'package:flutter/services.dart';

class NoteNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<NoteNode> children;

  NoteNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    List<NoteNode>? children,
  }) : children = children ?? [];
}

class AssetLoader {
  static Future<List<NoteNode>> loadNotesTree() async {
    // Modern Flutter asset manifest loading
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final markdownPaths = manifest
        .listAssets()
        .where((path) => path.startsWith('assets/data/') && path.endsWith('.md'))
        .toList();

    final List<NoteNode> rootNodes = [];

    for (final path in markdownPaths) {
      final relativePath = path.replaceFirst('assets/data/', '');
      final parts = relativePath.split('/');
      _insertNode(rootNodes, parts, path, 0);
    }

    return rootNodes;
  }

  static void _insertNode(
    List<NoteNode> currentLevel,
    List<String> pathParts,
    String fullPath,
    int index,
  ) {
    if (index >= pathParts.length) return;

    final name = pathParts[index];
    final isLastPart = index == pathParts.length - 1;

    if (isLastPart) {
      currentLevel.add(
        NoteNode(
          name: name.replaceAll('.md', '').replaceAll('_', ' '),
          path: fullPath,
          isDirectory: false,
        ),
      );
    } else {
      var folderNode = currentLevel.firstWhere(
        (node) => node.name == name && node.isDirectory,
        orElse: () {
          final newFolder = NoteNode(
            name: name,
            path: '',
            isDirectory: true,
          );
          currentLevel.add(newFolder);
          return newFolder;
        },
      );

      _insertNode(folderNode.children, pathParts, fullPath, index + 1);
    }
  }
}