import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'services/asset_loader.dart';
import 'theme/app_theme.dart';
import 'widgets/note_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isAppInitializing = true;

  @override
  void initState() {
    super.initState();
    _startAppInitialization();
  }

  Future<void> _startAppInitialization() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    setState(() {
      _isAppInitializing = false;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '.md The Notes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1200),
        switchInCurve: Curves.easeInOutCubicEmphasized,
        switchOutCurve: Curves.easeInOutCubic,
        child: _isAppInitializing
            ? const CustomSplashScreen(key: ValueKey('splash'))
            : HomeScreen(
                key: const ValueKey('home'),
                isDarkMode: _themeMode == ThemeMode.dark,
                onThemeChanged: _toggleTheme,
              ),
      ),
    );
  }
}

/// Minimal Splash Screen with refined breathing layout
class CustomSplashScreen extends StatelessWidget {
  const CustomSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 2.5,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteNode> _noteTree = [];
  String? _selectedNotePath;
  String _currentNoteContent = '';
  String _currentNoteTitle = 'Select A Note';
  bool _isLoadingContent = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatNoteTitle(String rawPath) {
    final fileName = rawPath
        .split('/')
        .last
        .replaceAll('.md', '')
        .replaceAll(RegExp(r'[-_]'), ' ');

    return fileName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _loadTree() async {
    final tree = await AssetLoader.loadNotesTree();
    if (!mounted) return;
    setState(() {
      _noteTree = tree;
    });
  }

  Future<void> _handleNoteSelected(String path) async {
    // 1. Close drawer smoothly
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // 2. Allow drawer close transition to settle
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // 3. Set loading state
    setState(() {
      _selectedNotePath = path;
      _isLoadingContent = true;
      _currentNoteTitle = _formatNoteTitle(path);
    });

    try {
      String content;
      if (path.startsWith('assets/')) {
        content = await rootBundle.loadString(path);
      } else {
        final file = File(path);
        content = await file.readAsString();
      }

      // Unhurried reading delay
      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;

      // Smoothly scroll back to top before showing new content
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }

      setState(() {
        _currentNoteContent = content;
        _isLoadingContent = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentNoteContent = '### Error loading file\n\n`$e`';
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _handleImportFile() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['md', 'txt'],
    );

    if (file != null && file.path != null) {
      await _handleNoteSelected(file.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final currentTheme = Theme.of(context);

    return AnimatedTheme(
      data: currentTheme,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      child: Scaffold(
        appBar: AppBar(
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            child: Text(
              _currentNoteTitle,
              key: ValueKey<String>(_currentNoteTitle),
            ),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.file_open_outlined),
            //   tooltip: 'Import Markdown File',
            //   onPressed: _handleImportFile,
            // ),
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: child.key == const ValueKey('dark')
                      ? Tween<double>(begin: 0.75, end: 1.0).animate(anim)
                      : Tween<double>(begin: 0.25, end: 1.0).animate(anim),
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: isDark
                    ? const Icon(Icons.light_mode_outlined, key: ValueKey('light'))
                    : const Icon(Icons.dark_mode_outlined, key: ValueKey('dark')),
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => widget.onThemeChanged(!isDark),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Divider(
              height: 1.0,
              thickness: 1.0,
              color: currentTheme.dividerColor,
            ),
          ),
        ),
        drawer: NoteDrawer(
          nodes: _noteTree,
          selectedNotePath: _selectedNotePath,
          onNoteSelected: _handleNoteSelected,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 900),
          reverseDuration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOutCubicEmphasized,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.025),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: _isLoadingContent
              ? Center(
                  key: const ValueKey('loading'),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor:
                              currentTheme.dividerColor.withOpacity(0.15),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Soft pulsing text
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.3, end: 0.8),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        builder: (context, opacity, child) {
                          return Opacity(
                            opacity: opacity,
                            child: child,
                          );
                        },
                        child: Text(
                          'Opening document...',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 0.6,
                            color: currentTheme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _currentNoteContent.isEmpty
                  ? const Center(
                      key: ValueKey('empty'),
                      child: Text(
                        'Select a note from the drawer to begin reading.',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    )
                  : KeyedSubtree(
                      key: ValueKey<String>(_selectedNotePath ?? 'content'),
                      child: Markdown(
                        controller: _scrollController,
                        data: _currentNoteContent,
                        selectable: true,
                        styleSheet: AppTheme.getMarkdownStyle(context),
                      ),
                    ),
        ),
      ),
    );
  }
}