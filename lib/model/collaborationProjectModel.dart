import 'package:twitterclone/model/collaborationModel.dart';

class CollaborationProject {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<CollaborationMember> members;
  final List<CollaborationDocument> documents;
  final ProjectSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivity;
  final bool isActive;
  final bool isPublic;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final ProjectStatistics statistics;
  
  CollaborationProject({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.members,
    required this.documents,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivity,
    this.isActive = true,
    this.isPublic = false,
    this.tags = const [],
    this.metadata = const {},
    required this.statistics,
  });
  
  factory CollaborationProject.fromJson(Map<String, dynamic> json) {
    final members = <CollaborationMember>[];
    if (json['members'] != null) {
      final membersList = json['members'] as List;
      for (final member in membersList) {
        members.add(CollaborationMember.fromJson(member));
      }
    }
    
    final documents = <CollaborationDocument>[];
    if (json['documents'] != null) {
      final documentsList = json['documents'] as List;
      for (final document in documentsList) {
        documents.add(CollaborationDocument.fromJson(document));
      }
    }
    
    return CollaborationProject(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      members: members,
      documents: documents,
      settings: ProjectSettings.fromJson(json['settings'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastActivity: json['lastActivity'] != null ? DateTime.parse(json['lastActivity']) : null,
      isActive: json['isActive'] ?? true,
      isPublic: json['isPublic'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] ?? {},
      statistics: ProjectStatistics.fromJson(json['statistics'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'members': members.map((m) => m.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastActivity': lastActivity?.toIso8601String(),
      'isActive': isActive,
      'isPublic': isPublic,
      'tags': tags,
      'metadata': metadata,
      'statistics': statistics.toJson(),
    };
  }
  
  CollaborationMember? get owner => members.firstWhere((m) => m.userId == ownerId);
  
  List<CollaborationMember> get activeMembers => members.where((m) => m.isActive).toList();
  
  List<CollaborationMember> get onlineMembers => members.where((m) => m.isOnline).toList();
  
  List<CollaborationDocument> get activeDocuments => documents.where((d) => !d.isArchived).toList();
  
  int get memberCount => members.length;
  
  int get onlineMemberCount => onlineMembers.length;
  
  int get documentCount => documents.length;
  
  int get activeDocumentCount => activeDocuments.length;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActivity ?? updatedAt);
    
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
  
  void addMember(CollaborationMember member) {
    if (!members.any((m) => m.userId == member.userId)) {
      members.add(member);
    }
  }
  
  void removeMember(String userId) {
    members.removeWhere((m) => m.userId == userId);
  }
  
  void addDocument(CollaborationDocument document) {
    if (!documents.any((d) => d.id == document.id)) {
      documents.add(document);
    }
  }
  
  void removeDocument(String documentId) {
    documents.removeWhere((d) => d.id == documentId);
  }
  
  CollaborationMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }
  
  CollaborationDocument? getDocument(String documentId) {
    try {
      return documents.firstWhere((d) => d.id == documentId);
    } catch (e) {
      return null;
    }
  }
  
  void updateLastActivity() {
    lastActivity = DateTime.now();
    updatedAt = DateTime.now();
  }
}

class ProjectSettings {
  final bool allowInvites;
  final bool requireApproval;
  final int maxMembers;
  final bool enableComments;
  final bool enableChat;
  final bool enableVersionHistory;
  final bool autoSave;
  final Duration autoSaveInterval;
  final List<CollaborationPermission> defaultPermissions;
  final Map<String, dynamic> customSettings;
  
  ProjectSettings({
    this.allowInvites = true,
    this.requireApproval = false,
    this.maxMembers = 50,
    this.enableComments = true,
    this.enableChat = true,
    this.enableVersionHistory = true,
    this.autoSave = true,
    this.autoSaveInterval = const Duration(minutes: 5),
    this.defaultPermissions = const [CollaborationPermission.read],
    this.customSettings = const {},
  });
  
  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    final defaultPermissions = <CollaborationPermission>[];
    if (json['defaultPermissions'] != null) {
      final permissionsList = json['defaultPermissions'] as List;
      for (final permission in permissionsList) {
        defaultPermissions.add(CollaborationPermissionExtension.fromString(permission));
      }
    }
    
    return ProjectSettings(
      allowInvites: json['allowInvites'] ?? true,
      requireApproval: json['requireApproval'] ?? false,
      maxMembers: json['maxMembers'] ?? 50,
      enableComments: json['enableComments'] ?? true,
      enableChat: json['enableChat'] ?? true,
      enableVersionHistory: json['enableVersionHistory'] ?? true,
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: Duration(minutes: json['autoSaveInterval'] ?? 5),
      defaultPermissions: defaultPermissions,
      customSettings: json['customSettings'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'allowInvites': allowInvites,
      'requireApproval': requireApproval,
      'maxMembers': maxMembers,
      'enableComments': enableComments,
      'enableChat': enableChat,
      'enableVersionHistory': enableVersionHistory,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval.inMinutes,
      'defaultPermissions': defaultPermissions.map((p) => p.name).toList(),
      'customSettings': customSettings,
    };
  }
}

class ProjectStatistics {
  final int totalDocuments;
  final int totalMembers;
  final int activeMembers;
  final int totalComments;
  final int totalEdits;
  final int totalViews;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  ProjectStatistics({
    required this.totalDocuments,
    required this.totalMembers,
    required this.activeMembers,
    required this.totalComments,
    required this.totalEdits,
    required this.totalViews,
    required this.createdAt,
    required this.lastUpdated,
  });
  
  factory ProjectStatistics.fromJson(Map<String, dynamic> json) {
    return ProjectStatistics(
      totalDocuments: json['totalDocuments'] ?? 0,
      totalMembers: json['totalMembers'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      totalComments: json['totalComments'] ?? 0,
      totalEdits: json['totalEdits'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'totalDocuments': totalDocuments,
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'totalComments': totalComments,
      'totalEdits': totalEdits,
      'totalViews': totalViews,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  double get memberEngagementRate {
    if (totalMembers == 0) return 0.0;
    return (activeMembers / totalMembers) * 100;
  }
  
  double get averageEditsPerDocument {
    if (totalDocuments == 0) return 0.0;
    return totalEdits / totalDocuments;
  }
  
  double get averageCommentsPerDocument {
    if (totalDocuments == 0) return 0.0;
    return totalComments / totalDocuments;
  }
}
