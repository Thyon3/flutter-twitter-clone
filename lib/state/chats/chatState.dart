import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:twitterclone/helper/enum.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:twitterclone/model/chatModel.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/state/appState.dart';
import 'package:twitterclone/state/authState.dart';

class ChatState extends AppState {
  late bool setIsChatScreenOpen; //!obsolete
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseReference _chatReference = FirebaseDatabase.instance.ref();

  List<ChatMessage> _messageList = [];
  List<ChatModel> _chatList = [];
  List<ChatModel> _pinnedChats = [];
  List<ChatModel> _archivedChats = [];
  UserModel? _chatUser;
  ChatModel? _currentChat;
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _error;
  String serverToken = "<FCM SERVER KEY>";
  Map<String, bool> _typingUsers = {};
  Map<String, DateTime> _lastSeen = {};

  // Getters
  List<ChatMessage> get messageList => _messageList;
  List<ChatModel> get chatList => _getSortedChats();
  List<ChatModel> get pinnedChats => _pinnedChats;
  List<ChatModel> get archivedChats => _archivedChats;
  UserModel? get chatUser => _chatUser;
  ChatModel? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  Map<String, bool> get typingUsers => _typingUsers;
  Map<String, DateTime> get lastSeen => _lastSeen;
  
  int get totalUnreadCount => _chatList.fold(0, (sum, chat) => sum + chat.unreadCount);
  bool get hasUnreadMessages => totalUnreadCount > 0;
  bool get hasChats => _chatList.isNotEmpty;
  bool get hasPinnedChats => _pinnedChats.isNotEmpty;
  bool get hasArchivedChats => _archivedChats.isNotEmpty;

  set setChatUser(UserModel model) {
    _chatUser = model;
  }

  String? _channelName;
  Query? messageQuery;

  /// Initialize chat state
  Future<void> initialize() async {
    await Future.wait([
      loadChatList(),
      setupFirebaseMessaging(),
    ]);
  }

  /// Load user's chat list
  Future<void> loadChatList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) {
        _chatList.clear();
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final snapshot = await _chatReference
          .child('chats')
          .orderByChild('participantIds')
          .arrayContains(userId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> chatsData = snapshot.value as Map;
        List<ChatModel> chats = [];
        
        for (var entry in chatsData.entries) {
          final chatData = Map<String, dynamic>.from(entry.value);
          chatData['id'] = entry.key.toString();
          
          final chat = ChatModel.fromJson(chatData);
          if (chat.participantIds.contains(userId)) {
            chats.add(chat);
          }
        }
        
        _chatList = chats;
        _separatePinnedAndArchivedChats();
      } else {
        _chatList.clear();
      }
    } catch (e) {
      _error = 'Failed to load chats: $e';
      print('Error loading chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load messages for a specific chat
  Future<void> loadMessages(String chatId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final snapshot = await _chatReference
          .child('messages')
          .child(chatId)
          .orderByChild('createdAt')
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> messagesData = snapshot.value as Map;
        List<ChatMessage> messages = [];
        
        for (var entry in messagesData.entries) {
          final messageData = Map<String, dynamic>.from(entry.value);
          messageData['id'] = entry.key.toString();
          
          final message = ChatMessage.fromJson(messageData);
          messages.add(message);
        }
        
        _messageList = messages;
        _sortMessages();
      } else {
        _messageList.clear();
      }
    } catch (e) {
      _error = 'Failed to load messages: $e';
      print('Error loading messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a message
  Future<String?> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      _isSendingMessage = true;
      notifyListeners();
      
      final authState = AuthState();
      final senderId = authState.userModel?.userId;
      final senderName = authState.userModel?.displayName;
      
      if (senderId == null) {
        _error = 'User not authenticated';
        return null;
      }
      
      final messageId = _chatReference.child('messages').child(chatId).push().key;
      final message = ChatMessage(
        id: messageId,
        senderId: senderId,
        receiverId: chatId, // This would need to be updated for group chats
        message: content,
        type: type,
        status: MessageStatus.sending,
        createdAt: DateTime.now().toIso8601String(),
        senderName: senderName,
        chatId: chatId,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        replyToMessageId: replyToMessageId,
      );
      
      // Save to database
      await _chatReference
          .child('messages')
          .child(chatId)
          .child(messageId!)
          .set(message.toJson());
      
      // Update chat's last message
      await updateChatLastMessage(chatId, content, senderId);
      
      // Add to local list
      _messageList.insert(0, message);
      _sortMessages();
      
      // Update message status to sent
      message.status = MessageStatus.sent;
      await _updateMessageStatus(chatId, messageId!, MessageStatus.sent);
      
      _isSendingMessage = false;
      _error = null;
      notifyListeners();
      
      // Send push notification to other participants
      await _sendPushNotification(chatId, message);
      
      return messageId;
    } catch (e) {
      _isSendingMessage = false;
      _error = 'Failed to send message: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update message status
  Future<void> _updateMessageStatus(String chatId, String messageId, MessageStatus status) async {
    try {
      await _chatReference
          .child('messages')
          .child(chatId)
          .child(messageId)
          .update({'status': status.name});
    } catch (e) {
      print('Error updating message status: $e');
    }
  }

  /// Mark messages as seen
  Future<void> markMessagesAsSeen(String chatId) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      // Get unread messages
      final unreadMessages = _messageList.where((message) => 
          message.receiverId == userId && message.status != MessageStatus.seen);
      
      // Update each message status
      for (final message in unreadMessages) {
        await _updateMessageStatus(chatId, message.id!, MessageStatus.seen);
        message.markAsSeen();
      }
      
      // Update chat unread count
      final chat = _chatList.firstWhere((c) => c.id == chatId);
      chat.markAsRead();
      await _updateChatInDatabase(chat);
      
      notifyListeners();
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

  /// Create a new chat
  Future<String?> createChat({
    required List<String> participantIds,
    String? name,
    ChatType type = ChatType.direct,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final chatId = _chatReference.child('chats').push().key;
      final chat = ChatModel(
        id: chatId,
        name: name,
        type: type,
        participantIds: participantIds,
        adminId: participantIds.first, // First participant as admin
        description: description,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to database
      await _chatReference
          .child('chats')
          .child(chatId!)
          .set(chat.toJson());
      
      // Add to local list
      _chatList.insert(0, chat);
      _separatePinnedAndArchivedChats();
      
      notifyListeners();
      return chatId;
    } catch (e) {
      _error = 'Failed to create chat: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update chat's last message
  Future<void> updateChatLastMessage(String chatId, String message, String senderId) async {
    try {
      final chat = _chatList.firstWhere((c) => c.id == chatId);
      chat.updateLastMessage(message, senderId);
      chat.incrementUnreadCount();
      await _updateChatInDatabase(chat);
      _sortChats();
      notifyListeners();
    } catch (e) {
      print('Error updating chat last message: $e');
    }
  }

  /// Update chat in database
  Future<void> _updateChatInDatabase(ChatModel chat) async {
    try {
      await _chatReference
          .child('chats')
          .child(chat.id!)
          .update(chat.toJson());
    } catch (e) {
      print('Error updating chat in database: $e');
    }
  }

  /// Set current chat
  void setCurrentChat(ChatModel? chat) {
    _currentChat = chat;
    if (chat != null) {
      loadMessages(chat.id!);
    }
    notifyListeners();
  }

  /// Toggle chat pin
  Future<void> togglePinChat(String chatId) async {
    try {
      final chat = _chatList.firstWhere((c) => c.id == chatId);
      chat.togglePin();
      await _updateChatInDatabase(chat);
      _separatePinnedAndArchivedChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle pin: $e';
      notifyListeners();
    }
  }

  /// Toggle chat mute
  Future<void> toggleMuteChat(String chatId) async {
    try {
      final chat = _chatList.firstWhere((c) => c.id == chatId);
      chat.toggleMute();
      await _updateChatInDatabase(chat);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle mute: $e';
      notifyListeners();
    }
  }

  /// Toggle chat archive
  Future<void> toggleArchiveChat(String chatId) async {
    try {
      final chat = _chatList.firstWhere((c) => c.id == chatId);
      chat.toggleArchive();
      await _updateChatInDatabase(chat);
      _separatePinnedAndArchivedChats();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to toggle archive: $e';
      notifyListeners();
    }
  }

  /// Delete chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatReference.child('chats').child(chatId).remove();
      await _chatReference.child('messages').child(chatId).remove();
      
      _chatList.removeWhere((c) => c.id == chatId);
      _pinnedChats.removeWhere((c) => c.id == chatId);
      _archivedChats.removeWhere((c) => c.id == chatId);
      
      if (_currentChat?.id == chatId) {
        _currentChat = null;
        _messageList.clear();
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete chat: $e';
      notifyListeners();
    }
  }

  /// Set typing indicator
  Future<void> setTyping(String chatId, bool isTyping) async {
    try {
      final authState = AuthState();
      final userId = authState.userModel?.userId;
      
      if (userId == null) return;
      
      await _chatReference
          .child('typing')
          .child(chatId)
          .child(userId)
          .set(isTyping);
      
      // Update local typing users
      if (isTyping) {
        _typingUsers[userId] = true;
      } else {
        _typingUsers.remove(userId);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error setting typing indicator: $e');
    }
  }

  /// Listen to typing indicators
  void _listenToTypingIndicators(String chatId) {
    _chatReference.child('typing').child(chatId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final typingData = Map<String, dynamic>.from(event.snapshot.value);
        _typingUsers.clear();
        
        for (var entry in typingData.entries) {
          if (entry.value == true) {
            _typingUsers[entry.key] = true;
          }
        }
        
        notifyListeners();
      }
    });
  }

  /// Send push notification
  Future<void> _sendPushNotification(String chatId, ChatMessage message) async {
    try {
      // This would implement FCM push notification sending
      // Implementation depends on your FCM server setup
      print('Sending push notification for message: ${message.message}');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  /// Setup Firebase messaging
  Future<void> setupFirebaseMessaging() async {
    try {
      // Request permission
      await firebaseMessaging.requestPermission();
      
      // Get FCM token
      final token = await firebaseMessaging.getToken();
      print('FCM Token: $token');
      
      // Handle incoming messages
      FirebaseMessaging.onMessage.listen(_handleFirebaseMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleFirebaseMessage);
    } catch (e) {
      print('Error setting up Firebase messaging: $e');
    }
  }

  /// Handle incoming Firebase messages
  void _handleFirebaseMessage(RemoteMessage message) {
    print('Received Firebase message: ${message.notification?.body}');
    
    // This would handle incoming push notifications
    // Update chat list, show notification, etc.
  }

  /// Sort messages by timestamp
  void _sortMessages() {
    _messageList.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.now();
      final bTime = b.timestamp ?? DateTime.now();
      return aTime.compareTo(bTime);
    });
  }

  /// Sort chats by last message time and pinned status
  void _sortChats() {
    _chatList.sort((a, b) {
      // Pinned chats first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then by last message time
      final aTime = a.lastMessageTime ?? DateTime(0);
      final bTime = b.lastMessageTime ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
  }

  /// Separate pinned and archived chats
  void _separatePinnedAndArchivedChats() {
    _pinnedChats = _chatList.where((chat) => chat.isPinned).toList();
    _archivedChats = _chatList.where((chat) => chat.isArchived).toList();
  }

  /// Get sorted chats (excluding archived)
  List<ChatModel> _getSortedChats() {
    return _chatList.where((chat) => !chat.isArchived).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await initialize();
  }

  /// Clear all data
  void clearAll() {
    _messageList.clear();
    _chatList.clear();
    _pinnedChats.clear();
    _archivedChats.clear();
    _currentChat = null;
    _typingUsers.clear();
    _lastSeen.clear();
    _error = null;
    notifyListeners();
  }

  /// Get sorted chats (excluding archived)
  List<ChatModel>? get chatUserList {
    if (_chatList.isEmpty) {
      return null;
    } else {
      return List.from(_chatList);
    }
  }
}
