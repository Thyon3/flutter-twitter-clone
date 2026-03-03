import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/user.dart';

class BookmarkModel {
  String? id;
  String? userId;
  String? tweetId;
  FeedModel? tweet;
  DateTime? createdAt;
  UserModel? user;
  List<String>? tags; // User-defined bookmark tags
  
  BookmarkModel({
    this.id,
    this.userId,
    this.tweetId,
    this.tweet,
    this.createdAt,
    this.user,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tweetId': tweetId,
      'tweet': tweet?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'user': user?.toJson(),
      'tags': tags,
    };
  }

  BookmarkModel.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    userId = map['userId'];
    tweetId = map['tweetId'];
    
    if (map['tweet'] != null) {
      tweet = FeedModel.fromJson(map['tweet']);
    }
    
    createdAt = map['createdAt'] != null 
        ? DateTime.parse(map['createdAt']) 
        : DateTime.now();
    
    if (map['user'] != null) {
      user = UserModel.fromJson(map['user']);
    }
    
    if (map['tags'] != null) {
      tags = List<String>.from(map['tags']);
    }
  }

  /// Check if bookmark is valid
  bool get isValid {
    return id != null && 
           id!.isNotEmpty && 
           userId != null && 
           userId!.isNotEmpty &&
           tweetId != null && 
           tweetId!.isNotEmpty;
  }

  /// Get bookmark age
  String getTimeAgo() {
    if (createdAt == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if bookmark has specific tag
  bool hasTag(String tag) {
    return tags?.contains(tag) ?? false;
  }

  /// Add tag to bookmark
  void addTag(String tag) {
    if (tags == null) {
      tags = [];
    }
    if (!hasTag(tag)) {
      tags!.add(tag);
    }
  }

  /// Remove tag from bookmark
  void removeTag(String tag) {
    tags?.remove(tag);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ?? 0;

  @override
  String toString() {
    return 'BookmarkModel{id: $id, tweetId: $tweetId, createdAt: $createdAt}';
  }
}

class BookmarkFolder {
  String? id;
  String? name;
  String? userId;
  List<String> bookmarkIds;
  DateTime? createdAt;
  String? description;
  String? emoji; // Folder emoji icon
  
  BookmarkFolder({
    this.id,
    this.name,
    this.userId,
    List<String>? bookmarkIds,
    this.createdAt,
    this.description,
    this.emoji,
  }) : bookmarkIds = bookmarkIds ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'bookmarkIds': bookmarkIds,
      'createdAt': createdAt?.toIso8601String(),
      'description': description,
      'emoji': emoji,
    };
  }

  BookmarkFolder.fromJson(Map<dynamic, dynamic> map) {
    id = map['id'];
    name = map['name'];
    userId = map['userId'];
    
    if (map['bookmarkIds'] != null) {
      bookmarkIds = List<String>.from(map['bookmarkIds']);
    } else {
      bookmarkIds = [];
    }
    
    createdAt = map['createdAt'] != null 
        ? DateTime.parse(map['createdAt']) 
        : DateTime.now();
    
    description = map['description'];
    emoji = map['emoji'];
  }

  /// Get bookmark count
  int get bookmarkCount => bookmarkIds.length;

  /// Check if folder is valid
  bool get isValid {
    return id != null && 
           id!.isNotEmpty && 
           userId != null && 
           userId!.isNotEmpty &&
           name != null && 
           name!.isNotEmpty;
  }

  /// Add bookmark to folder
  void addBookmark(String bookmarkId) {
    if (!bookmarkIds.contains(bookmarkId)) {
      bookmarkIds.add(bookmarkId);
    }
  }

  /// Remove bookmark from folder
  void removeBookmark(String bookmarkId) {
    bookmarkIds.remove(bookmarkId);
  }

  /// Check if folder contains bookmark
  bool containsBookmark(String bookmarkId) {
    return bookmarkIds.contains(bookmarkId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookmarkFolder && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ?? 0;

  @override
  String toString() {
    return 'BookmarkFolder{id: $id, name: $name, count: $bookmarkCount}';
  }
}

enum BookmarkSortOption {
  newestFirst,
  oldestFirst,
  mostRecent,
  leastRecent,
  alphabeticalAZ,
  alphabeticalZA,
}

extension BookmarkSortOptionExtension on BookmarkSortOption {
  String get displayName {
    switch (this) {
      case BookmarkSortOption.newestFirst:
        return 'Newest first';
      case BookmarkSortOption.oldestFirst:
        return 'Oldest first';
      case BookmarkSortOption.mostRecent:
        return 'Most recent';
      case BookmarkSortOption.leastRecent:
        return 'Least recent';
      case BookmarkSortOption.alphabeticalAZ:
        return 'Alphabetical (A-Z)';
      case BookmarkSortOption.alphabeticalZA:
        return 'Alphabetical (Z-A)';
    }
  }
}
