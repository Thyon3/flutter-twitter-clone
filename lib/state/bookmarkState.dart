import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:twitterclone/model/bookmarkModel.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/base/tweetBaseState.dart';

class BookmarkState extends TweetBaseState {
  final DatabaseReference _bookmarkReference = FirebaseDatabase.instance.ref();
  
  List<BookmarkModel> _bookmarks = [];
  List<BookmarkFolder> _folders = [];
  bool _isLoading = false;
  bool _isCreatingFolder = false;
  String? _error;
  BookmarkSortOption _currentSortOption = BookmarkSortOption.newestFirst;
  String? _selectedFolderId;
  
  // Getters
  List<BookmarkModel> get bookmarks => _getSortedBookmarks();
  List<BookmarkFolder> get folders => _folders;
  bool get isLoading => _isLoading;
  bool get isCreatingFolder => _isCreatingFolder;
  String? get error => _error;
  BookmarkSortOption get currentSortOption => _currentSortOption;
  String? get selectedFolderId => _selectedFolderId;
  
  int get bookmarkCount => _bookmarks.length;
  int get folderCount => _folders.length;
  bool get hasBookmarks => _bookmarks.isNotEmpty;
  bool get hasFolders => _folders.isNotEmpty;
  
  /// Initialize bookmark state
  Future<void> initialize() async {
    await Future.wait([
      loadBookmarks(),
      loadFolders(),
    ]);
  }
  
  /// Load user's bookmarks
  Future<void> loadBookmarks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        _bookmarks.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final snapshot = await _bookmarkReference
          .child('bookmarks')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> bookmarksData = snapshot.value as Map;
        List<BookmarkModel> bookmarks = [];
        
        for (var entry in bookmarksData.entries) {
          final bookmarkData = Map<String, dynamic>.from(entry.value);
          bookmarkData['id'] = entry.key.toString();
          
          final bookmark = BookmarkModel.fromJson(bookmarkData);
          if (bookmark.isValid) {
            bookmarks.add(bookmark);
          }
        }
        
        _bookmarks = bookmarks;
      } else {
        _bookmarks.clear();
      }
    } catch (e) {
      _error = 'Failed to load bookmarks: $e';
      print('Error loading bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load user's bookmark folders
  Future<void> loadFolders() async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        _folders.clear();
        notifyListeners();
        return;
      }
      
      final snapshot = await _bookmarkReference
          .child('bookmarkFolders')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> foldersData = snapshot.value as Map;
        List<BookmarkFolder> folders = [];
        
        for (var entry in foldersData.entries) {
          final folderData = Map<String, dynamic>.from(entry.value);
          folderData['id'] = entry.key.toString();
          
          final folder = BookmarkFolder.fromJson(folderData);
          if (folder.isValid) {
            folders.add(folder);
          }
        }
        
        _folders = folders;
      } else {
        _folders.clear();
      }
    } catch (e) {
      _error = 'Failed to load bookmark folders: $e';
      print('Error loading bookmark folders: $e');
    } finally {
      notifyListeners();
    }
  }
  
  /// Create a new bookmark
  Future<String?> createBookmark({
    required String tweetId,
    FeedModel? tweet,
    List<String>? tags,
    String? folderId,
  }) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        return null;
      }
      
      // Check if bookmark already exists
      if (_bookmarks.any((bookmark) => bookmark.tweetId == tweetId)) {
        _error = 'Tweet already bookmarked';
        notifyListeners();
        return null;
      }
      
      final bookmarkId = _bookmarkReference.child('bookmarks').push().key;
      final bookmark = BookmarkModel(
        id: bookmarkId,
        userId: userId,
        tweetId: tweetId,
        tweet: tweet,
        tags: tags ?? [],
        createdAt: DateTime.now(),
      );
      
      // Save to database
      await _bookmarkReference
          .child('bookmarks')
          .child(bookmarkId!)
          .set(bookmark.toJson());
      
      // Add to local list
      _bookmarks.insert(0, bookmark);
      
      // Add to folder if specified
      if (folderId != null) {
        await addBookmarkToFolder(folderId, bookmarkId!);
      }
      
      _error = null;
      notifyListeners();
      return bookmarkId;
    } catch (e) {
      _error = 'Failed to create bookmark: $e';
      print('Error creating bookmark: $e');
      notifyListeners();
      return null;
    }
  }
  
  /// Remove a bookmark
  Future<bool> removeBookmark(String bookmarkId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        return false;
      }
      
      // Remove from database
      await _bookmarkReference
          .child('bookmarks')
          .child(bookmarkId)
          .remove();
      
      // Remove from all folders
      for (var folder in _folders) {
        if (folder.containsBookmark(bookmarkId)) {
          await removeBookmarkFromFolder(folder.id!, bookmarkId);
        }
      }
      
      // Remove from local list
      _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove bookmark: $e';
      print('Error removing bookmark: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Check if tweet is bookmarked
  bool isTweetBookmarked(String tweetId) {
    return _bookmarks.any((bookmark) => bookmark.tweetId == tweetId);
  }
  
  /// Get bookmark by tweet ID
  BookmarkModel? getBookmarkByTweetId(String tweetId) {
    try {
      return _bookmarks.firstWhere((bookmark) => bookmark.tweetId == tweetId);
    } catch (e) {
      return null;
    }
  }
  
  /// Create a new folder
  Future<String?> createFolder({
    required String name,
    String? description,
    String? emoji,
  }) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        return null;
      }
      
      _isCreatingFolder = true;
      notifyListeners();
      
      final folderId = _bookmarkReference.child('bookmarkFolders').push().key;
      final folder = BookmarkFolder(
        id: folderId,
        name: name,
        userId: userId,
        description: description,
        emoji: emoji,
        createdAt: DateTime.now(),
      );
      
      // Save to database
      await _bookmarkReference
          .child('bookmarkFolders')
          .child(folderId!)
          .set(folder.toJson());
      
      // Add to local list
      _folders.insert(0, folder);
      
      _isCreatingFolder = false;
      _error = null;
      notifyListeners();
      return folderId;
    } catch (e) {
      _isCreatingFolder = false;
      _error = 'Failed to create folder: $e';
      print('Error creating folder: $e');
      notifyListeners();
      return null;
    }
  }
  
  /// Delete a folder
  Future<bool> deleteFolder(String folderId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        return false;
      }
      
      // Remove from database
      await _bookmarkReference
          .child('bookmarkFolders')
          .child(folderId)
          .remove();
      
      // Remove from local list
      _folders.removeWhere((folder) => folder.id == folderId);
      
      // Clear selected folder if it was deleted
      if (_selectedFolderId == folderId) {
        _selectedFolderId = null;
      }
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete folder: $e';
      print('Error deleting folder: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Add bookmark to folder
  Future<void> addBookmarkToFolder(String folderId, String bookmarkId) async {
    try {
      final folder = _folders.firstWhere((f) => f.id == folderId);
      if (!folder.containsBookmark(bookmarkId)) {
        folder.addBookmark(bookmarkId);
        
        // Update in database
        await _bookmarkReference
            .child('bookmarkFolders')
            .child(folderId)
            .update({'bookmarkIds': folder.bookmarkIds});
      }
    } catch (e) {
      print('Error adding bookmark to folder: $e');
    }
  }
  
  /// Remove bookmark from folder
  Future<void> removeBookmarkFromFolder(String folderId, String bookmarkId) async {
    try {
      final folder = _folders.firstWhere((f) => f.id == folderId);
      if (folder.containsBookmark(bookmarkId)) {
        folder.removeBookmark(bookmarkId);
        
        // Update in database
        await _bookmarkReference
            .child('bookmarkFolders')
            .child(folderId)
            .update({'bookmarkIds': folder.bookmarkIds});
      }
    } catch (e) {
      print('Error removing bookmark from folder: $e');
    }
  }
  
  /// Set sort option
  void setSortOption(BookmarkSortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }
  
  /// Set selected folder
  void setSelectedFolder(String? folderId) {
    _selectedFolderId = folderId;
    notifyListeners();
  }
  
  /// Get bookmarks in selected folder
  List<BookmarkModel> getBookmarksInFolder(String? folderId) {
    if (folderId == null) return _getSortedBookmarks();
    
    final folder = _folders.firstWhere((f) => f.id == folderId);
    return _getSortedBookmarks()
        .where((bookmark) => folder.containsBookmark(bookmark.id!))
        .toList();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Get sorted bookmarks based on current sort option
  List<BookmarkModel> _getSortedBookmarks() {
    final bookmarks = List<BookmarkModel>.from(_bookmarks);
    
    switch (_currentSortOption) {
      case BookmarkSortOption.newestFirst:
        bookmarks.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        break;
      case BookmarkSortOption.oldestFirst:
        bookmarks.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
      case BookmarkSortOption.alphabeticalAZ:
        bookmarks.sort((a, b) => (a.tweet?.user?.displayName ?? '').compareTo(b.tweet?.user?.displayName ?? ''));
        break;
      case BookmarkSortOption.alphabeticalZA:
        bookmarks.sort((a, b) => (b.tweet?.user?.displayName ?? '').compareTo(a.tweet?.user?.displayName ?? ''));
        break;
      default:
        break;
    }
    
    return bookmarks;
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
  
  /// Clear all data
  void clearAll() {
    _bookmarks.clear();
    _folders.clear();
    _selectedFolderId = null;
    _currentSortOption = BookmarkSortOption.newestFirst;
    _error = null;
    notifyListeners();
  }
}
