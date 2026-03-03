import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/bookmarkModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/bookmarkState.dart';
import 'package:twitterclone/ui/page/common/locator.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';
import 'package:twitterclone/widgets/tweet/tweet.dart';
import 'package:twitterclone/widgets/tweet/widgets/tweetBottomSheet.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({Key? key}) : super(key: key);

  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
      await bookmarkState.initialize();
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookmarks: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBookmarks() async {
    final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
    await bookmarkState.refresh();
  }

  void _showSortOptions() {
    final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort bookmarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...BookmarkSortOption.values.map((option) => ListTile(
              title: Text(option.displayName),
              trailing: bookmarkState.currentSortOption == option
                  ? const Icon(Icons.check, color: AppColor.primary)
                  : null,
              onTap: () {
                bookmarkState.setSortOption(option);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showFolderOptions() {
    final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select folder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All bookmarks'),
              trailing: bookmarkState.selectedFolderId == null
                  ? const Icon(Icons.check, color: AppColor.primary)
                  : null,
              onTap: () {
                bookmarkState.setSelectedFolder(null);
                Navigator.pop(context);
              },
            ),
            ...bookmarkState.folders.map((folder) => ListTile(
              title: Text(folder.name),
              subtitle: Text('${folder.bookmarkCount} bookmarks'),
              leading: Text(
                folder.emoji ?? '📁',
                style: const TextStyle(fontSize: 24),
              ),
              trailing: bookmarkState.selectedFolderId == folder.id
                  ? const Icon(Icons.check, color: AppColor.primary)
                  : null,
              onTap: () {
                bookmarkState.setSelectedFolder(folder.id);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    final emojiController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Folder name',
                hintText: 'Enter folder name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: 'Emoji (optional)',
                hintText: '📁',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter description',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
              await bookmarkState.createFolder(
                name: controller.text.trim(),
                emoji: emojiController.text.trim().isEmpty 
                    ? null 
                    : emojiController.text.trim(),
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
              );

              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkState = Provider.of<BookmarkState>(context);
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Bookmarks'),
            Tab(text: 'Folders'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFolderOptions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookmarksTab(),
          _buildFoldersTab(),
        ],
      ),
    );
  }

  Widget _buildBookmarksTab() {
    final bookmarkState = Provider.of<BookmarkState>(context);
    final bookmarks = bookmarkState.selectedFolderId != null
        ? bookmarkState.getBookmarksInFolder(bookmarkState.selectedFolderId)
        : bookmarkState.bookmarks;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookmarks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!bookmarkState.hasBookmarks) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_border,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookmarks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save tweets to see them here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookmarks,
      child: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          if (bookmark.tweet == null) {
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              Tweet(
                model: bookmark.tweet!,
                scaffoldKey: GlobalKey<ScaffoldState>(),
                type: TweetType.Tweet,
              ),
              if (index < bookmarks.length - 1)
                const Divider(height: 1, color: Colors.grey),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFoldersTab() {
    final bookmarkState = Provider.of<BookmarkState>(context);

    if (!bookmarkState.hasFolders) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No folders yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create folders to organize your bookmarks',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateFolderDialog,
              icon: const Icon(Icons.create_new_folder),
              label: const Text('Create folder'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bookmarkState.folderCount} folders',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCreateFolderDialog,
                icon: const Icon(Icons.create_new_folder),
                label: const Text('Create folder'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: bookmarkState.folders.length,
            itemBuilder: (context, index) {
              final folder = bookmarkState.folders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Text(
                    folder.emoji ?? '📁',
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    folder.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    folder.description ?? '${folder.bookmarkCount} bookmarks',
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteFolderDialog(folder);
                      }
                    },
                  ),
                  onTap: () {
                    bookmarkState.setSelectedFolder(folder.id);
                    _tabController.animateTo(0);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteFolderDialog(BookmarkFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? '
          'The bookmarks will be moved to "All bookmarks".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final bookmarkState = Provider.of<BookmarkState>(context, listen: false);
              await bookmarkState.deleteFolder(folder.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
