import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/note_node.dart';

class WorkspaceService {
  Directory rootDir;

  WorkspaceService(this.rootDir);

  /// 1. Scan root directory recursively and return a NoteNode tree
  Future<List<NoteNode>> loadWorkspaceTree() async {
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }
    return await _buildTree(rootDir);
  }

  /// Recursively walks directories and creates file/folder nodes
  Future<List<NoteNode>> _buildTree(Directory dir) async {
    List<NoteNode> nodes = [];

    try {
      final List<FileSystemEntity> entities =
          await dir.list(followLinks: false).toList();

      for (var entity in entities) {
        final name = path.basename(entity.path);

        // Skip hidden system files/folders (e.g. .git, .obsidian)
        if (name.startsWith('.')) continue;

        if (entity is Directory) {
          final children = await _buildTree(entity);
          nodes.add(
            NoteNode(
              name: name,
              path: entity.path,
              isDirectory: true,
              children: children,
            ),
          );
        } else if (entity is File && entity.path.endsWith('.md')) {
          nodes.add(
            NoteNode(
              name: name,
              path: entity.path,
              isDirectory: false,
            ),
          );
        }
      }

      // Sort tree: Folders first, then files alphabetically
      nodes.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    } catch (e) {
      // Gracefully ignore permission errors on system folders
    }

    return nodes;
  }

  /// 2. Read Markdown content from disk
  Future<String> readNoteContent(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  /// 3. Save Markdown content back to disk
  Future<void> saveNoteContent(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  /// 4. Create a new .md file inside target folder
  Future<File> createNote({
    required String parentFolderPath,
    required String fileName,
  }) async {
    final cleanName = fileName.endsWith('.md') ? fileName : '$fileName.md';
    final fullPath = path.join(parentFolderPath, cleanName);
    final file = File(fullPath);
    await file.create(recursive: true);
    return file;
  }

  /// 5. Create a new sub-folder inside target folder
  Future<Directory> createFolder({
    required String parentFolderPath,
    required String folderName,
  }) async {
    final fullPath = path.join(parentFolderPath, folderName);
    final directory = Directory(fullPath);
    return await directory.create(recursive: true);
  }

  /// 6. Import/Upload an external file into workspace
  Future<File?> importExternalFile(String targetFolderPath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      final sourceFile = File(result.files.single.path!);
      final fileName = path.basename(sourceFile.path);
      final destinationPath = path.join(targetFolderPath, fileName);
      return await sourceFile.copy(destinationPath);
    }
    return null;
  }
}