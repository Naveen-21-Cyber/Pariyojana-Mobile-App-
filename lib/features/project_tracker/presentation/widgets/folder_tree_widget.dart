import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/velvet_colors.dart';
import '../../../../shared_widgets/clay_card.dart';

class TreeNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<TreeNode> children;
  bool isExpanded;

  TreeNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
    this.isExpanded = false,
  });
}

class FolderTreeWidget extends StatefulWidget {
  final String? storagePath;
  final String? mockSubfoldersJson;

  const FolderTreeWidget({
    super.key,
    this.storagePath,
    this.mockSubfoldersJson,
  });

  @override
  State<FolderTreeWidget> createState() => _FolderTreeWidgetState();
}

class _FolderTreeWidgetState extends State<FolderTreeWidget> {
  TreeNode? _rootNode;
  bool _isRealFilesystem = false;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  @override
  void didUpdateWidget(covariant FolderTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.storagePath != oldWidget.storagePath) {
      _loadTree();
    }
  }

  void _loadTree() {
    final path = widget.storagePath;
    if (path == null || path.isEmpty) {
      setState(() {
        _rootNode = null;
      });
      return;
    }

    final dir = Directory(path);
    if (dir.existsSync()) {
      setState(() {
        _isRealFilesystem = true;
        _rootNode = _buildTreeFromFilesystem(dir);
        _rootNode?.isExpanded = true;
      });
    } else {
      setState(() {
        _isRealFilesystem = false;
        _rootNode = _buildMockTree(path);
      });
    }
  }

  TreeNode _buildTreeFromFilesystem(Directory dir) {
    final List<TreeNode> children = [];
    try {
      final list = dir.listSync();
      for (final entity in list) {
        final name = entity.path.split(Platform.pathSeparator).last;
        if (entity is Directory) {
          children.add(_buildTreeFromFilesystem(entity));
        } else if (entity is File) {
          children.add(TreeNode(
            name: name,
            path: entity.path,
            isDirectory: false,
          ));
        }
      }
      // Sort: folders first, then files alphabetically
      children.sort((a, b) {
        if (a.isDirectory != b.isDirectory) {
          return a.isDirectory ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
    } catch (_) {}

    return TreeNode(
      name: dir.path.split(Platform.pathSeparator).last,
      path: dir.path,
      isDirectory: true,
      children: children,
    );
  }

  TreeNode _buildMockTree(String basePath) {
    return TreeNode(
      name: basePath.split(Platform.pathSeparator).last,
      path: basePath,
      isDirectory: true,
      isExpanded: true,
      children: [
        TreeNode(
          name: 'src',
          path: '$basePath/src',
          isDirectory: true,
          isExpanded: true,
          children: [
            TreeNode(name: 'main.dart', path: '$basePath/src/main.dart', isDirectory: false),
            TreeNode(name: 'app.dart', path: '$basePath/src/app.dart', isDirectory: false),
          ],
        ),
        TreeNode(
          name: 'assets',
          path: '$basePath/assets',
          isDirectory: true,
          children: [
            TreeNode(name: 'logo.png', path: '$basePath/assets/logo.png', isDirectory: false),
          ],
        ),
        TreeNode(name: 'pubspec.yaml', path: '$basePath/pubspec.yaml', isDirectory: false),
        TreeNode(name: 'README.md', path: '$basePath/README.md', isDirectory: false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_rootNode == null) {
      return const SizedBox.shrink();
    }

    return ClayCard(
      color: VelvetColors.cardSurface(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skeuo Folder Tree',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: VelvetColors.textPrimary(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (_isRealFilesystem ? VelvetColors.mint : VelvetColors.periwinkle)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isRealFilesystem ? 'Local FS' : 'Simulated FS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _isRealFilesystem ? VelvetColors.mint : VelvetColors.periwinkle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNodeRow(_rootNode!, 0),
        ],
      ),
    );
  }

  Widget _buildNodeRow(TreeNode node, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: node.isDirectory
              ? () {
                  setState(() {
                    node.isExpanded = !node.isExpanded;
                  });
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                // Indentation lines representing tree branches
                for (int i = 0; i < depth; i++)
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 6),
                    width: 1.5,
                    height: 20,
                    color: VelvetColors.border(context),
                  ),
                if (depth > 0) const SizedBox(width: 4),
                Icon(
                  node.isDirectory
                      ? (node.isExpanded
                          ? Icons.folder_open_rounded
                          : Icons.folder_rounded)
                      : Icons.insert_drive_file_outlined,
                  size: 18,
                  color: node.isDirectory
                      ? VelvetColors.coralPeach
                      : VelvetColors.iconColor(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: node.isDirectory ? null : 'JetBrains Mono',
                      fontWeight: node.isDirectory ? FontWeight.bold : FontWeight.normal,
                      color: VelvetColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (node.isDirectory && node.isExpanded)
          ...node.children.map((child) => _buildNodeRow(child, depth + 1)),
      ],
    );
  }
}
