// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../helper/utility.dart';
import '../model/feedModel.dart';
import '../model/notificationModel.dart';
import '../model/user.dart';
import '../resource/push_notification_service.dart';
import '../ui/page/common/locator.dart';
import 'appState.dart';
import 'authState.dart';

enum NotificationFilter {
  all,
  unread,
  mentions,
  follows,
  likes,
  retweets,
  comments,
  quotes,
  bookmarks,
  polls,
}

extension NotificationFilterExtension on NotificationFilter {
  String get displayName {
    switch (this) {
      case NotificationFilter.all:
        return 'All';
      case NotificationFilter.unread:
        return 'Unread';
      case NotificationFilter.mentions:
        return 'Mentions';
      case NotificationFilter.follows:
        return 'Follows';
      case NotificationFilter.likes:
        return 'Likes';
      case NotificationFilter.retweets:
        return 'Retweets';
      case NotificationFilter.comments:
        return 'Comments';
      case NotificationFilter.quotes:
        return 'Quotes';
      case NotificationFilter.bookmarks:
        return 'Bookmarks';
      case NotificationFilter.polls:
        return 'Polls';
    }
  }
}

class NotificationState extends AppState {
  final DatabaseReference _notificationReference = FirebaseDatabase.instance.ref();
  
  dabase.Query? query;
  List<UserModel> userList = [];
  List<NotificationModel> _notificationList = [];
  List<NotificationModel> _pinnedNotifications = [];
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  
  // Getters
  List<NotificationModel> get notificationList => _getFilteredNotifications();
  List<NotificationModel> get pinnedNotifications => _pinnedNotifications;
  NotificationFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasNotifications => _notificationList.isNotEmpty;
  bool get hasUnreadNotifications => _unreadCount > 0;

  addNotificationList(NotificationModel model) {
    if (!_notificationList.any((element) => element.id == model.id)) {
      _notificationList.insert(0, model);
      
      // Update unread count
      if (!model.isRead) {
        _unreadCount++;
      }
      
      // Update pinned notifications
      if (model.isPinned) {
        _pinnedNotifications.add(model);
      }
    }
  }

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      if (query != null) {
        query!.onValue.drain();
        query = null;
        _notificationList.clear();
        _pinnedNotifications.clear();
        _unreadCount = 0;
      }
      query = kDatabase.child("notification").child(userId);
      query!.onChildAdded.listen(_onNotificationAdded);
      query!.onChildChanged.listen(_onNotificationChanged);
      query!.onChildRemoved.listen(_onNotificationRemoved);

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Notification list] from firebase realtime database
  Future<void> getDataFromDatabase(String userId) async {
    try {
      if (_notificationList.isNotEmpty) {
        return;
      }
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final snapshot = await kDatabase
          .child('notification')
          .child(userId)
          .once();
      
      if (snapshot.value != null) {
        final map = snapshot.value as Map<dynamic, dynamic>?;
        if (map != null) {
          for (var entry in map.entries) {
            final notificationData = Map<String, dynamic>.from(entry.value);
            final model = NotificationModel.fromJson(entry.key.toString(), notificationData);
            addNotificationList(model);
          }
          _sortNotifications();
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _error = 'Failed to load notifications: $error';
      cprint(error, errorIn: 'getDataFromDatabase');
      notifyListeners();
    }
  }

  /// Create a new notification
  Future<String?> createNotification({
    required String userId,
    required String senderId,
    required NotificationType type,
    String? tweetKey,
    Map<String, dynamic>? data,
    String? message,
    String? imageUrl,
  }) async {
    try {
      final notificationId = _notificationReference.child('notifications').push().key;
      final notification = NotificationModel(
        id: notificationId,
        userId: userId,
        senderId: senderId,
        tweetKey: tweetKey,
        type: type,
        createdAt: DateTime.now().toIso8601String(),
        data: data,
        message: message,
        imageUrl: imageUrl,
      );
      
      // Save to database
      await _notificationReference
          .child('notification')
          .child(userId)
          .child(notificationId!)
          .set(notification.toJson());
      
      return notificationId;
    } catch (e) {
      _error = 'Failed to create notification: $e';
      notifyListeners();
      return null;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      await _notificationReference
          .child('notification')
          .child(userId)
          .child(notificationId)
          .update({'isRead': true});
      
      // Update local state
      final notification = _notificationList.firstWhere((n) => n.id == notificationId);
      notification.markAsRead();
      
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      // Update all unread notifications
      final unreadNotifications = _notificationList.where((n) => !n.isRead);
      
      for (final notification in unreadNotifications) {
        await _notificationReference
            .child('notification')
            .child(userId)
            .child(notification.id!)
            .update({'isRead': true});
        notification.markAsRead();
      }
      
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
    }
  }

  /// Pin/unpin notification
  Future<void> togglePin(String notificationId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      final notification = _notificationList.firstWhere((n) => n.id == notificationId);
      notification.togglePin();
      
      await _notificationReference
          .child('notification')
          .child(userId)
          .child(notificationId)
          .update({'isPinned': notification.isPinned});
      
      // Update pinned notifications list
      if (notification.isPinned) {
        _pinnedNotifications.add(notification);
      } else {
        _pinnedNotifications.removeWhere((n) => n.id == notificationId);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle pin: $e';
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      await _notificationReference
          .child('notification')
          .child(userId)
          .child(notificationId)
          .remove();
      
      // Update local state
      _notificationList.removeWhere((n) => n.id == notificationId);
      _pinnedNotifications.removeWhere((n) => n.id == notificationId);
      
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete notification: $e';
      notifyListeners();
    }
  }

  /// Set notification filter
  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Get filtered notifications
  List<NotificationModel> _getFilteredNotifications() {
    List<NotificationModel> notifications = List.from(_notificationList);
    
    switch (_currentFilter) {
      case NotificationFilter.unread:
        notifications = notifications.where((n) => !n.isRead).toList();
        break;
      case NotificationFilter.mentions:
        notifications = notifications.where((n) => n.type == NotificationType.mention).toList();
        break;
      case NotificationFilter.follows:
        notifications = notifications.where((n) => n.type == NotificationType.follow).toList();
        break;
      case NotificationFilter.likes:
        notifications = notifications.where((n) => n.type == NotificationType.like).toList();
        break;
      case NotificationFilter.retweets:
        notifications = notifications.where((n) => n.type == NotificationType.retweet).toList();
        break;
      case NotificationFilter.comments:
        notifications = notifications.where((n) => n.type == NotificationType.comment).toList();
        break;
      case NotificationFilter.quotes:
        notifications = notifications.where((n) => n.type == NotificationType.quoteTweet).toList();
        break;
      case NotificationFilter.bookmarks:
        notifications = notifications.where((n) => n.type == NotificationType.bookmark).toList();
        break;
      case NotificationFilter.polls:
        notifications = notifications.where((n) => n.type == NotificationType.pollVote).toList();
        break;
      case NotificationFilter.all:
      default:
        break;
    }
    
    return notifications;
  }

  /// Sort notifications by timestamp (newest first)
  void _sortNotifications() {
    _notificationList.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return (b.timeStamp ?? DateTime.now()).compareTo(a.timeStamp ?? DateTime.now());
    });
    
    _pinnedNotifications.sort((a, b) => 
        (b.timeStamp ?? DateTime.now()).compareTo(a.timeStamp ?? DateTime.now()));
  }

  /// get `Tweet` present in notification
  Future<FeedModel?> getTweetDetail(String tweetId) async {
    FeedModel _tweetDetail;
    var event = await kDatabase.child('tweet').child(tweetId).once();
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      _tweetDetail = FeedModel.fromJson(map);
      _tweetDetail.key = event.snapshot.key!;
      return _tweetDetail;
    } else {
      return null;
    }
  }

  /// get user who liked your tweet
  Future<UserModel?> getUserDetail(String userId) async {
    UserModel user;
    if (userList.isNotEmpty && userList.any((x) => x.userId == userId)) {
      return Future.value(userList.firstWhere((x) => x.userId == userId));
    }
    var event = await kDatabase.child('profile').child(userId).once();

    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      user = UserModel.fromJson(map);
      user.key = event.snapshot.key!;
      userList.add(user);
      return user;
    } else {
      return null;
    }
  }

  /// Remove notification if related Tweet is not found or deleted
  void removeNotification(String userId, String tweetkey) async {
    kDatabase.child('notification').child(userId).child(tweetkey).remove();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key!, map);

      addNotificationList(model);
      _sortNotifications();
      print("Notification added");
      notifyListeners();
    }
  }

  /// Trigger when someone changed his like preference
  void _onNotificationChanged(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key!, map);
      
      // Update existing notification
      final index = _notificationList.indexWhere((n) => n.id == model.id);
      if (index != -1) {
        _notificationList[index] = model;
        _sortNotifications();
      }
      
      print("Notification changed");
      notifyListeners();
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      var map = event.snapshot.value as Map<dynamic, dynamic>;
      var model = NotificationModel.fromJson(event.snapshot.key!, map);
      
      // remove notification from list
      _notificationList.removeWhere((x) => x.id == model.id);
      _pinnedNotifications.removeWhere((x) => x.id == model.id);
      
      if (!model.isRead && _unreadCount > 0) {
        _unreadCount--;
      }
      
      notifyListeners();
      print("Notification Removed");
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refresh() async {
    final authState = AuthState();
    final userId = authState.userModel?.userId;
    
    if (userId != null) {
      await getDataFromDatabase(userId);
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notificationList.clear();
    _pinnedNotifications.clear();
    _unreadCount = 0;
    _currentFilter = NotificationFilter.all;
    _error = null;
    notifyListeners();
  }

  /// Initilise push notification services
  void initFirebaseService() {
    if (!getIt.isRegistered<PushNotificationService>()) {
      getIt.registerSingleton<PushNotificationService>(
          PushNotificationService(FirebaseMessaging.instance));
    }
  }

  @override
  void dispose() {
    getIt.unregister<PushNotificationService>();
    super.dispose();
  }
}
