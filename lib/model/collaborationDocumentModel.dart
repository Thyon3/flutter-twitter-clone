import 'package:twitterclone/model/collaborationModel.dart';

class CollaborationDocument {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final ContentType type;
  final String authorId;
  final List<String> coAuthors;
  final List<DocumentVersion> versions;
  final List<DocumentComment> comments;
  final List<DocumentLock> locks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastEdited;
  final String? lastEditedBy;
  final bool isPublished;
  final bool isArchived;
  final bool isLocked;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DocumentStatistics statistics;
  final List<DocumentChange> changeHistory;
  
  CollaborationDocument({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.type,
    required this.authorId,
    required this.coAuthors,
    required this.versions,
    required this.comments,
    required this.locks,
    required this.createdAt,
    required this.updatedAt,
    this.lastEdited,
    this.lastEditedBy,
    this.isPublished = false,
    this.isArchived = false,
    this.isLocked = false,
    this.metadata = const {},
    this.tags = const [],
    required this.statistics,
    required this.changeHistory,
  });
  
  factory CollaborationDocument.fromJson(Map<String, dynamic> json) {
    final coAuthors = <String>[];
    if (json['coAuthors'] != null) {
      coAuthors = List<String>.from(json['coAuthors']);
    }
    
    final versions = <DocumentVersion>[];
    if (json['versions'] != null) {
      final versionsList = json['versions'] as List;
      for (final version in versionsList) {
        versions.add(DocumentVersion.fromJson(version));
      }
    }
    
    final comments = <DocumentComment>[];
    if (json['comments'] != null) {
      final commentsList = json['comments'] as List;
      for (final comment in commentsList) {
        comments.add(DocumentComment.fromJson(comment));
      }
    }
    
    final locks = <DocumentLock>[];
    if (json['locks'] != null) {
      final locksList = json['locks'] as List;
      for (final lock in locksList) {
        locks.add(DocumentLock.fromJson(lock));
      }
    }
    
    final changeHistory = <DocumentChange>[];
    if (json['changeHistory'] != null) {
      final changesList = json['changeHistory'] as List;
      for (final change in changesList) {
        changeHistory.add(DocumentChange.fromJson(change));
      }
    }
    
    return CollaborationDocument(
      id: json['id'],
      projectId: json['projectId'],
      title: json['title'],
      content: json['content'],
      type: ContentTypeExtension.fromString(json['type']),
      authorId: json['authorId'],
      coAuthors: coAuthors,
      versions: versions,
      comments: comments,
      locks: locks,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastEdited: json['lastEdited'] != null ? DateTime.parse(json['lastEdited']) : null,
      lastEditedBy: json['lastEditedBy'],
      isPublished: json['isPublished'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isLocked: json['isLocked'] ?? false,
      metadata: json['metadata'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      statistics: DocumentStatistics.fromJson(json['statistics'] ?? {}),
      changeHistory: changeHistory,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'content': content,
      'type': type.name,
      'authorId': authorId,
      'coAuthors': coAuthors,
      'versions': versions.map((v) => v.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'locks': locks.map((l) => l.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastEdited': lastEdited?.toIso8601String(),
      'lastEditedBy': lastEditedBy,
      'isPublished': isPublished,
      'isArchived': isArchived,
      'isLocked': isLocked,
      'metadata': metadata,
      'tags': tags,
      'statistics': statistics.toJson(),
      'changeHistory': changeHistory.map((c) => c.toJson()).toList(),
    };
  }
  
  DocumentVersion get currentVersion => versions.last;
  
  List<String> get allAuthors => [authorId, ...coAuthors];
  
  int get versionCount => versions.length;
  
  int get commentCount => comments.length;
  
  String get wordCount => content.split(' ').length.toString();
  
  String get characterCount => content.length.toString();
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastEdited ?? updatedAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
  
  void addCoAuthor(String userId) {
    if (!coAuthors.contains(userId)) {
      coAuthors.add(userId);
    }
  }
  
  void removeCoAuthor(String userId) {
    coAuthors.remove(userId);
  }
  
  void addComment(DocumentComment comment) {
    comments.add(comment);
  }
  
  void addVersion(DocumentVersion version) {
    versions.add(version);
  }
  
  void addChange(DocumentChange change) {
    changeHistory.add(change);
  }
  
  void lock(String userId, String reason) {
    locks.add(DocumentLock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: id,
      userId: userId,
      reason: reason,
      createdAt: DateTime.now(),
    ));
    isLocked = true;
  }
  
  void unlock() {
    locks.clear();
    isLocked = false;
  }
  
  DocumentLock? getCurrentLock() {
    return locks.isNotEmpty ? locks.last : null;
  }
}

class DocumentVersion {
  final String id;
  final String documentId;
  final int versionNumber;
  final String content;
  final String authorId;
  final String? changeDescription;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
  
  DocumentVersion({
    required this.id,
    required this.documentId,
    required this.versionNumber,
    required this.content,
    required this.authorId,
    this.changeDescription,
    required this.createdAt,
    this.metadata = const {},
  });
  
  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'],
      documentId: json['documentId'],
      versionNumber: json['versionNumber'],
      content: json['content'],
      authorId: json['authorId'],
      changeDescription: json['changeDescription'],
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'versionNumber': versionNumber,
      'content': content,
      'authorId': authorId,
      'changeDescription': changeDescription,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class DocumentComment {
  final String id;
  final String documentId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentId;
  final List<String> mentions;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  
  DocumentComment({
    required this.id,
    required this.documentId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.parentId,
    this.mentions = const [],
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
  });
  
  factory DocumentComment.fromJson(Map<String, dynamic> json) {
    return DocumentComment(
      id: json['id'],
      documentId: json['documentId'],
      authorId: json['authorId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      parentId: json['parentId'],
      mentions: List<String>.from(json['mentions'] ?? []),
      isResolved: json['isResolved'] ?? false,
      resolvedBy: json['resolvedBy'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parentId': parentId,
      'mentions': mentions,
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
  
  bool get isReply => parentId != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}

class DocumentLock {
  final String id;
  final String documentId;
  final String userId;
  final String reason;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  DocumentLock({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.reason,
    required this.createdAt,
    this.expiresAt,
  });
  
  factory DocumentLock.fromJson(Map<String, dynamic> json) {
    return DocumentLock(
      id: json['id'],
      documentId: json['documentId'],
      userId: json['userId'],
      reason: json['reason'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'userId': userId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

class DocumentStatistics {
  final int views;
  final int edits;
  final int comments;
  final int shares;
  final int downloads;
  final int uniqueViewers;
  final DateTime firstView;
  final DateTime lastView;
  final Map<String, int> viewsByDate;
  
  DocumentStatistics({
    required this.views,
    required this.edits,
    required this.comments,
    required this.shares,
    required this.downloads,
    required this.uniqueViewers,
    required this.firstView,
    required this.lastView,
    required this.viewsByDate,
  });
  
  factory DocumentStatistics.fromJson(Map<String, dynamic> json) {
    return DocumentStatistics(
      views: json['views'] ?? 0,
      edits: json['edits'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      downloads: json['downloads'] ?? 0,
      uniqueViewers: json['uniqueViewers'] ?? 0,
      firstView: DateTime.parse(json['firstView'] ?? DateTime.now().toIso8601String()),
      lastView: DateTime.parse(json['lastView'] ?? DateTime.now().toIso8601String()),
      viewsByDate: Map<String, int>.from(json['viewsByDate'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'views': views,
      'edits': edits,
      'comments': comments,
      'shares': shares,
      'downloads': downloads,
      'uniqueViewers': uniqueViewers,
      'firstView': firstView.toIso8601String(),
      'lastView': lastView.toIso8601String(),
      'viewsByDate': viewsByDate,
    };
  }
  
  double get engagementRate {
    final totalInteractions = comments + shares + downloads;
    return views > 0 ? (totalInteractions / views) * 100 : 0.0;
  }
}

class DocumentChange {
  final String id;
  final String documentId;
  final String userId;
  final ChangeType changeType;
  final String? oldValue;
  final String? newValue;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  DocumentChange({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.changeType,
    this.oldValue,
    this.newValue,
    this.description,
    required this.timestamp,
    this.metadata = const {},
  });
  
  factory DocumentChange.fromJson(Map<String, dynamic> json) {
    return DocumentChange(
      id: json['id'],
      documentId: json['documentId'],
      userId: json['userId'],
      changeType: ChangeTypeExtension.fromString(json['changeType']),
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'userId': userId,
      'changeType': changeType.name,
      'oldValue': oldValue,
      'newValue': newValue,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
