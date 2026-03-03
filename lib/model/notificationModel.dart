import 'dart:convert';

import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/model/feedModel.dart';

enum NotificationType {
  like,
  retweet,
  comment,
  mention,
  follow,
  message,
  quoteTweet,
  pollVote,
  threadUpdate,
  bookmark,
  listAddition,
  spaceReminder,
  verification,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.like:
        return 'Like';
      case NotificationType.retweet:
        return 'Retweet';
      case NotificationType.comment:
        return 'Comment';
      case NotificationType.mention:
        return 'Mention';
      case NotificationType.follow:
        return 'Follow';
      case NotificationType.message:
        return 'Message';
      case NotificationType.quoteTweet:
        return 'Quote Tweet';
      case NotificationType.pollVote:
        return 'Poll Vote';
      case NotificationType.threadUpdate:
        return 'Thread Update';
      case NotificationType.bookmark:
        return 'Bookmark';
      case NotificationType.listAddition:
        return 'List Addition';
      case NotificationType.spaceReminder:
        return 'Space Reminder';
      case NotificationType.verification:
        return 'Verification';
      case NotificationType.system:
        return 'System';
    }
  }

  String get iconPath {
    switch (this) {
      case NotificationType.like:
        return 'assets/icons/like.png';
      case NotificationType.retweet:
        return 'assets/icons/retweet.png';
      case NotificationType.comment:
        return 'assets/icons/comment.png';
      case NotificationType.mention:
        return 'assets/icons/mention.png';
      case NotificationType.follow:
        return 'assets/icons/follow.png';
      case NotificationType.message:
        return 'assets/icons/message.png';
      case NotificationType.quoteTweet:
        return 'assets/icons/quote.png';
      case NotificationType.pollVote:
        return 'assets/icons/poll.png';
      case NotificationType.threadUpdate:
        return 'assets/icons/thread.png';
      case NotificationType.bookmark:
        return 'assets/icons/bookmark.png';
      case NotificationType.listAddition:
        return 'assets/icons/list.png';
      case NotificationType.spaceReminder:
        return 'assets/icons/space.png';
      case NotificationType.verification:
        return 'assets/icons/verification.png';
      case NotificationType.system:
        return 'assets/icons/system.png';
    }
  }

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'like':
        return NotificationType.like;
      case 'retweet':
        return NotificationType.retweet;
      case 'comment':
        return NotificationType.comment;
      case 'mention':
        return NotificationType.mention;
      case 'follow':
        return NotificationType.follow;
      case 'message':
        return NotificationType.message;
      case 'quotetweet':
        return NotificationType.quoteTweet;
      case 'pollvote':
        return NotificationType.pollVote;
      case 'threadupdate':
        return NotificationType.threadUpdate;
      case 'bookmark':
        return NotificationType.bookmark;
      case 'listaddition':
        return NotificationType.listAddition;
      case 'spacereminder':
        return NotificationType.spaceReminder;
      case 'verification':
        return NotificationType.verification;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

class NotificationModel {
  String? id;
  String? userId; // User who receives the notification
  String? senderId; // User who triggered the notification
  String? tweetKey;
  String? updatedAt;
  String? createdAt;
  late NotificationType type;
  Map<String, dynamic>? data;
  bool isRead;
  bool isPinned;
  String? message;
  String? imageUrl;
  
  NotificationModel({
    this.id,
    this.userId,
    this.senderId,
    this.tweetKey,
    required this.type,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.isRead = false,
    this.isPinned = false,
    this.message,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'senderId': senderId,
      'tweetKey': tweetKey,
      'type': type.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'data': data,
      'isRead': isRead,
      'isPinned': isPinned,
      'message': message,
      'imageUrl': imageUrl,
    };
  }

  NotificationModel.fromJson(String notificationId, Map<dynamic, dynamic> map) {
    id = notificationId;
    userId = map['userId'];
    senderId = map['senderId'];
    tweetKey = map['tweetKey'];
    type = NotificationTypeExtension.fromString(map['type'] ?? 'system');
    createdAt = map['createdAt'];
    updatedAt = map['updatedAt'];
    
    if (map.containsKey('data')) {
      data = Map<String, dynamic>.from(map['data']);
    }
    
    isRead = map['isRead'] ?? false;
    isPinned = map['isPinned'] ?? false;
    message = map['message'];
    imageUrl = map['imageUrl'];
  }

  /// Get notification title based on type
  String get title {
    switch (type) {
      case NotificationType.like:
        return '${senderUser?.displayName ?? 'Someone'} liked your tweet';
      case NotificationType.retweet:
        return '${senderUser?.displayName ?? 'Someone'} retweeted your tweet';
      case NotificationType.comment:
        return '${senderUser?.displayName ?? 'Someone'} commented on your tweet';
      case NotificationType.mention:
        return '${senderUser?.DisplayName ?? 'Someone'} mentioned you';
      case NotificationType.follow:
        return '${senderUser?.displayName ?? 'Someone'} followed you';
      case NotificationType.message:
        return '${senderUser?.displayName ?? 'Someone'} sent you a message';
      case NotificationType.quoteTweet:
        return '${senderUser?.displayName ?? 'Someone'} quoted your tweet';
      case NotificationType.pollVote:
        return '${senderUser?.displayName ?? 'Someone'} voted on your poll';
      case NotificationType.threadUpdate:
        return '${senderUser?.displayName ?? 'Someone'} added to your thread';
      case NotificationType.bookmark:
        return '${senderUser?.displayName ?? 'Someone'} bookmarked your tweet';
      case NotificationType.listAddition:
        return '${senderUser?.displayName ?? 'Someone'} added you to a list';
      case NotificationType.spaceReminder:
        return 'Reminder: Space starting soon';
      case NotificationType.verification:
        return 'Your account has been verified!';
      case NotificationType.system:
        return message ?? 'System notification';
    }
  }

  /// Get notification subtitle/description
  String get subtitle {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    
    switch (type) {
      case NotificationType.like:
      case NotificationType.retweet:
      case NotificationType.comment:
      case NotificationType.quoteTweet:
      case NotificationType.bookmark:
        return tweet?.description ?? '';
      case NotificationType.mention:
        return tweet?.description ?? '';
      case NotificationType.follow:
        return senderUser?.bio ?? '';
      case NotificationType.message:
        return data?['messagePreview'] ?? '';
      case NotificationType.pollVote:
        return data?['pollQuestion'] ?? '';
      case NotificationType.threadUpdate:
        return data?['threadDescription'] ?? '';
      case NotificationType.listAddition:
        return data?['listName'] ?? '';
      case NotificationType.spaceReminder:
        return data?['spaceTitle'] ?? '';
      case NotificationType.verification:
        return 'You can now access verified features';
      case NotificationType.system:
        return '';
    }
  }

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent {
    if (timeStamp == null) return false;
    final now = DateTime.now();
    final difference = now.difference(timeStamp!);
    return difference.inHours < 24;
  }

  /// Get time ago string
  String getTimeAgo() {
    if (timeStamp == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(timeStamp!);
    
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

  /// Mark notification as read
  void markAsRead() {
    isRead = true;
  }

  /// Pin/unpin notification
  void togglePin() {
    isPinned = !isPinned;
  }
}

extension NotificationModelHelper on NotificationModel {
  UserModel? get senderUser {
    if (data != null && data!.containsKey('user')) {
      return UserModel.fromJson(data!['user']);
    }
    return null;
  }

  FeedModel? get tweet {
    if (data != null && data!.containsKey('tweet')) {
      return FeedModel.fromJson(data!['tweet']);
    }
    return null;
  }

  DateTime? get timeStamp => updatedAt != null || createdAt != null
      ? DateTime.tryParse(updatedAt ?? createdAt!)
      : null;

  /// Check if notification is actionable
  bool get isActionable {
    switch (type) {
      case NotificationType.like:
      case NotificationType.retweet:
      case NotificationType.comment:
      case NotificationType.mention:
      case NotificationType.quoteTweet:
      case NotificationType.bookmark:
      case NotificationType.pollVote:
        return tweetKey != null;
      case NotificationType.follow:
      case NotificationType.message:
      case NotificationType.listAddition:
        return senderId != null;
      case NotificationType.threadUpdate:
      case NotificationType.spaceReminder:
      case NotificationType.verification:
      case NotificationType.system:
        return true;
    }
  }
}
