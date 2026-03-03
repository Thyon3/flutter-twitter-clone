import 'package:twitterclone/model/user.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
  gif,
  file,
  location,
  contact,
  poll,
  tweet,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
  failed,
}

enum ChatStatus {
  active,
  away,
  busy,
  offline,
}

enum ChatType {
  direct,
  group,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.video:
        return 'Video';
      case MessageType.audio:
        return 'Audio';
      case MessageType.gif:
        return 'GIF';
      case MessageType.file:
        return 'File';
      case MessageType.location:
        return 'Location';
      case MessageType.contact:
        return 'Contact';
      case MessageType.poll:
        return 'Poll';
      case MessageType.tweet:
        return 'Tweet';
      case MessageType.system:
        return 'System';
    }
  }

  static MessageType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'gif':
        return MessageType.gif;
      case 'file':
        return MessageType.file;
      case 'location':
        return MessageType.location;
      case 'contact':
        return MessageType.contact;
      case 'poll':
        return MessageType.poll;
      case 'tweet':
        return MessageType.tweet;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.seen:
        return 'Seen';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  static MessageStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'seen':
        return MessageStatus.seen;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sending;
    }
  }
}

class ChatMessage {
  String? id;
  String senderId;
  String receiverId;
  String? message;
  MessageType type;
  MessageStatus status;
  String? createdAt;
  String? updatedAt;
  String? senderName;
  String? receiverName;
  String? chatId;
  
  // Media attachments
  String? imageUrl;
  String? videoUrl;
  String? audioUrl;
  String? fileUrl;
  String? fileName;
  int? fileSize;
  
  // Location data
  double? latitude;
  double? longitude;
  String? locationName;
  
  // Reply data
  String? replyToMessageId;
  ChatMessage? replyToMessage;
  
  // Forward data
  String? forwardedFromUserId;
  String? forwardedFromChatId;
  bool isForwarded;
  
  // Reaction data
  Map<String, String>? reactions;
  
  // Edit data
  bool isEdited;
  String? originalMessage;
  String? editedAt;
  
  // Delete data
  bool isDeleted;
  String? deletedAt;
  
  // Typing indicator
  bool isTyping;
  
  ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.type = MessageType.text,
    this.status = MessageStatus.sending,
    this.createdAt,
    this.updatedAt,
    this.senderName,
    this.receiverName,
    this.chatId,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.latitude,
    this.longitude,
    this.locationName,
    this.replyToMessageId,
    this.replyToMessage,
    this.forwardedFromUserId,
    this.forwardedFromChatId,
    this.isForwarded = false,
    this.reactions,
    this.isEdited = false,
    this.originalMessage,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
    this.isTyping = false,
  });

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'],
      type: MessageTypeExtension.fromString(json['type'] ?? 'text'),
      status: MessageStatusExtension.fromString(json['status'] ?? 'sending'),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      senderName: json['senderName'],
      receiverName: json['receiverName'],
      chatId: json['chatId'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      audioUrl: json['audioUrl'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationName: json['locationName'],
      replyToMessageId: json['replyToMessageId'],
      forwardedFromUserId: json['forwardedFromUserId'],
      forwardedFromChatId: json['forwardedFromChatId'],
      isForwarded: json['isForwarded'] ?? false,
      reactions: json['reactions'] != null 
          ? Map<String, String>.from(json['reactions'])
          : null,
      isEdited: json['isEdited'] ?? false,
      originalMessage: json['originalMessage'],
      editedAt: json['editedAt'],
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'],
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'senderName': senderName,
      'receiverName': receiverName,
      'chatId': chatId,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'replyToMessageId': replyToMessageId,
      'forwardedFromUserId': forwardedFromUserId,
      'forwardedFromChatId': forwardedFromChatId,
      'isForwarded': isForwarded,
      'reactions': reactions,
      'isEdited': isEdited,
      'originalMessage': originalMessage,
      'editedAt': editedAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'isTyping': isTyping,
    };
  }

  /// Get message display text
  String get displayText {
    if (isDeleted) return 'This message was deleted';
    
    switch (type) {
      case MessageType.text:
        return message ?? '';
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.gif:
        return '🎬 GIF';
      case MessageType.file:
        return '📎 File${fileName != null ? ': $fileName' : ''}';
      case MessageType.location:
        return '📍 Location${locationName != null ? ': $locationName' : ''};
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.poll:
        return '📊 Poll';
      case MessageType.tweet:
        return '🐦 Tweet';
      case MessageType.system:
        return message ?? 'System message';
    }
  }

  /// Get message timestamp
  DateTime? get timestamp {
    if (createdAt != null) {
      return DateTime.tryParse(createdAt!);
    }
    return null;
  }

  /// Get time ago string
  String getTimeAgo() {
    if (timestamp == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    
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

  /// Check if message is from current user
  bool get isFromCurrentUser {
    // This would need to be implemented based on current user context
    return false;
  }

  /// Mark message as seen
  void markAsSeen() {
    status = MessageStatus.seen;
    updatedAt = DateTime.now().toIso8601String();
  }

  /// Mark message as delivered
  void markAsDelivered() {
    status = MessageStatus.delivered;
    updatedAt = DateTime.now().toIso8601String();
  }

  /// Mark message as failed
  void markAsFailed() {
    status = MessageStatus.failed;
    updatedAt = DateTime.now().toIso8601String();
  }

  /// Add reaction to message
  void addReaction(String userId, String emoji) {
    reactions ??= {};
    reactions![userId] = emoji;
    updatedAt = DateTime.now().toIso8601String();
  }

  /// Remove reaction from message
  void removeReaction(String userId) {
    reactions?.remove(userId);
    updatedAt = DateTime.now().toIso8601String();
  }

  /// Edit message
  void editMessage(String newMessage) {
    if (type == MessageType.text && !isDeleted) {
      originalMessage = message;
      message = newMessage;
      isEdited = true;
      editedAt = DateTime.now().toIso8601String();
      updatedAt = editedAt;
    }
  }

  /// Delete message
  void deleteMessage() {
    isDeleted = true;
    deletedAt = DateTime.now().toIso8601String();
    updatedAt = deletedAt;
    message = null;
    imageUrl = null;
    videoUrl = null;
    audioUrl = null;
    fileUrl = null;
  }

  /// Check if message has media
  bool get hasMedia {
    return imageUrl != null || 
           videoUrl != null || 
           audioUrl != null || 
           fileUrl != null;
  }

  /// Check if message has reactions
  bool get hasReactions {
    return reactions != null && reactions!.isNotEmpty;
  }

  /// Get reaction count
  int get reactionCount {
    return reactions?.length ?? 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ?? 0;

  @override
  String toString() {
    return 'ChatMessage{id: $id, type: $type, status: $status, message: $message}';
  }
}

class ChatModel {
  String? id;
  String? name;
  ChatType type;
  List<String> participantIds;
  String? adminId;
  String? description;
  String? imageUrl;
  String? lastMessage;
  String? lastMessageSenderId;
  DateTime? lastMessageTime;
  int unreadCount;
  bool isMuted;
  bool isPinned;
  bool isArchived;
  ChatStatus status;
  Map<String, ChatStatus>? participantStatus;
  Map<String, DateTime>? lastSeen;
  DateTime? createdAt;
  DateTime? updatedAt;

  ChatModel({
    this.id,
    this.name,
    this.type = ChatType.direct,
    required this.participantIds,
    this.adminId,
    this.description,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isPinned = false,
    this.isArchived = false,
    this.status = ChatStatus.offline,
    this.participantStatus,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatModel(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'group' ? ChatType.group : ChatType.direct,
      participantIds: List<String>.from(json['participantIds'] ?? []),
      adminId: json['adminId'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      lastMessage: json['lastMessage'],
      lastMessageSenderId: json['lastMessageSenderId'],
      lastMessageTime: json['lastMessageTime'] != null 
          ? DateTime.tryParse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isMuted: json['isMuted'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isArchived: json['isArchived'] ?? false,
      status: ChatStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ChatStatus.offline,
      ),
      participantStatus: json['participantStatus'] != null
          ? Map<String, ChatStatus>.from(
              json['participantStatus'].map((k, v) => 
                MapEntry(k, ChatStatus.values.firstWhere(
                  (s) => s.name == v,
                  orElse: () => ChatStatus.offline,
                ))
              )
            )
          : null,
      lastSeen: json['lastSeen'] != null
          ? Map<String, DateTime>.from(
              json['lastSeen'].map((k, v) => 
                MapEntry(k, DateTime.tryParse(v) ?? DateTime.now())
              )
            )
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'participantIds': participantIds,
      'adminId': adminId,
      'description': description,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'isMuted': isMuted,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'status': status.name,
      'participantStatus': participantStatus?.map((k, v) => MapEntry(k, v.name)),
      'lastSeen': lastSeen?.map((k, v) => MapEntry(k, v.toIso8601String())),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get chat display name
  String get displayName {
    if (type == ChatType.group) {
      return name ?? 'Group Chat';
    } else {
      return name ?? 'Direct Message';
    }
  }

  /// Get chat subtitle
  String get subtitle {
    if (isMuted) return 'Muted';
    if (lastMessage != null) return lastMessage!;
    return 'No messages yet';
  }

  /// Check if chat is group
  bool get isGroup => type == ChatType.group;

  /// Check if chat is direct
  bool get isDirect => type == ChatType.direct;

  /// Get participant count
  int get participantCount => participantIds.length;

  /// Update last message
  void updateLastMessage(String message, String senderId) {
    lastMessage = message;
    lastMessageSenderId = senderId;
    lastMessageTime = DateTime.now();
    updatedAt = lastMessageTime;
  }

  /// Increment unread count
  void incrementUnreadCount() {
    unreadCount++;
    updatedAt = DateTime.now();
  }

  /// Mark as read
  void markAsRead() {
    unreadCount = 0;
    updatedAt = DateTime.now();
  }

  /// Toggle mute
  void toggleMute() {
    isMuted = !isMuted;
    updatedAt = DateTime.now();
  }

  /// Toggle pin
  void togglePin() {
    isPinned = !isPinned;
    updatedAt = DateTime.now();
  }

  /// Toggle archive
  void toggleArchive() {
    isArchived = !isArchived;
    updatedAt = DateTime.now();
  }

  /// Update participant status
  void updateParticipantStatus(String userId, ChatStatus status) {
    participantStatus ??= {};
    participantStatus![userId] = status;
    updatedAt = DateTime.now();
  }

  /// Update last seen
  void updateLastSeen(String userId) {
    lastSeen ??= {};
    lastSeen![userId] = DateTime.now();
    updatedAt = DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ?? 0;

  @override
  String toString() {
    return 'ChatModel{id: $id, name: $name, type: $type, participantCount: $participantCount}';
  }
}
