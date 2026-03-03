enum CollaborationRole {
  owner,
  admin,
  editor,
  viewer,
  commenter,
}

enum CollaborationPermission {
  read,
  write,
  edit,
  delete,
  share,
  invite,
  manage,
}

enum CollaborationStatus {
  active,
  pending,
  declined,
  removed,
  archived,
}

enum ContentType {
  tweet,
  thread,
  draft,
  media,
  document,
}

enum ChangeType {
  create,
  edit,
  delete,
  move,
  comment,
  share,
  invite,
  permission,
}

enum SyncStatus {
  synced,
  pending,
  conflict,
  error,
}

enum PresenceStatus {
  online,
  away,
  busy,
  offline,
}

extension CollaborationRoleExtension on CollaborationRole {
  String get displayName {
    switch (this) {
      case CollaborationRole.owner:
        return 'Owner';
      case CollaborationRole.admin:
        return 'Admin';
      case CollaborationRole.editor:
        return 'Editor';
      case CollaborationRole.viewer:
        return 'Viewer';
      case CollaborationRole.commenter:
        return 'Commenter';
    }
  }

  String get description {
    switch (this) {
      case CollaborationRole.owner:
        return 'Full control over the collaboration';
      case CollaborationRole.admin:
        return 'Can manage collaboration and content';
      case CollaborationRole.editor:
        return 'Can edit and create content';
      case CollaborationRole.viewer:
        return 'Can only view content';
      case CollaborationRole.commenter:
        return 'Can view and comment on content';
    }
  }

  List<CollaborationPermission> get permissions {
    switch (this) {
      case CollaborationRole.owner:
        return CollaborationPermission.values;
      case CollaborationRole.admin:
        return [
          CollaborationPermission.read,
          CollaborationPermission.write,
          CollaborationPermission.edit,
          CollaborationPermission.delete,
          CollaborationPermission.share,
          CollaborationPermission.invite,
          CollaborationPermission.manage,
        ];
      case CollaborationRole.editor:
        return [
          CollaborationPermission.read,
          CollaborationPermission.write,
          CollaborationPermission.edit,
        ];
      case CollaborationRole.viewer:
        return [CollaborationPermission.read];
      case CollaborationRole.commenter:
        return [
          CollaborationPermission.read,
          CollaborationPermission.write, // for comments
        ];
    }
  }

  static CollaborationRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return CollaborationRole.owner;
      case 'admin':
        return CollaborationRole.admin;
      case 'editor':
        return CollaborationRole.editor;
      case 'viewer':
        return CollaborationRole.viewer;
      case 'commenter':
        return CollaborationRole.commenter;
      default:
        return CollaborationRole.viewer;
    }
  }
}

extension CollaborationPermissionExtension on CollaborationPermission {
  String get displayName {
    switch (this) {
      case CollaborationPermission.read:
        return 'Read';
      case CollaborationPermission.write:
        return 'Write';
      case CollaborationPermission.edit:
        return 'Edit';
      case CollaborationPermission.delete:
        return 'Delete';
      case CollaborationPermission.share:
        return 'Share';
      case CollaborationPermission.invite:
        return 'Invite';
      case CollaborationPermission.manage:
        return 'Manage';
    }
  }

  String get icon {
    switch (this) {
      case CollaborationPermission.read:
        return '👁️';
      case CollaborationPermission.write:
        return '✏️';
      case CollaborationPermission.edit:
        return '📝';
      case CollaborationPermission.delete:
        return '🗑️';
      case CollaborationPermission.share:
        return '🔗';
      case CollaborationPermission.invite:
        return '👥';
      case CollaborationPermission.manage:
        return '⚙️';
    }
  }

  static CollaborationPermission fromString(String permission) {
    switch (permission.toLowerCase()) {
      case 'read':
        return CollaborationPermission.read;
      case 'write':
        return CollaborationPermission.write;
      case 'edit':
        return CollaborationPermission.edit;
      case 'delete':
        return CollaborationPermission.delete;
      case 'share':
        return CollaborationPermission.share;
      case 'invite':
        return CollaborationPermission.invite;
      case 'manage':
        return CollaborationPermission.manage;
      default:
        return CollaborationPermission.read;
    }
  }
}

extension CollaborationStatusExtension on CollaborationStatus {
  String get displayName {
    switch (this) {
      case CollaborationStatus.active:
        return 'Active';
      case CollaborationStatus.pending:
        return 'Pending';
      case CollaborationStatus.declined:
        return 'Declined';
      case CollaborationStatus.removed:
        return 'Removed';
      case CollaborationStatus.archived:
        return 'Archived';
    }
  }

  String get color {
    switch (this) {
      case CollaborationStatus.active:
        return '#28a745'; // Green
      case CollaborationStatus.pending:
        return '#ffc107'; // Yellow
      case CollaborationStatus.declined:
        return '#dc3545'; // Red
      case CollaborationStatus.removed:
        return '#6c757d'; // Gray
      case CollaborationStatus.archived:
        return '#6f42c1'; // Purple
    }
  }

  static CollaborationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return CollaborationStatus.active;
      case 'pending':
        return CollaborationStatus.pending;
      case 'declined':
        return CollaborationStatus.declined;
      case 'removed':
        return CollaborationStatus.removed;
      case 'archived':
        return CollaborationStatus.archived;
      default:
        return CollaborationStatus.pending;
    }
  }
}

extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.tweet:
        return 'Tweet';
      case ContentType.thread:
        return 'Thread';
      case ContentType.draft:
        return 'Draft';
      case ContentType.media:
        return 'Media';
      case ContentType.document:
        return 'Document';
    }
  }

  String get icon {
    switch (this) {
      case ContentType.tweet:
        return '🐦';
      case ContentType.thread:
        return '🧵';
      case ContentType.draft:
        return '📝';
      case ContentType.media:
        return '🖼️';
      case ContentType.document:
        return '📄';
    }
  }

  static ContentType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'tweet':
        return ContentType.tweet;
      case 'thread':
        return ContentType.thread;
      case 'draft':
        return ContentType.draft;
      case 'media':
        return ContentType.media;
      case 'document':
        return ContentType.document;
      default:
        return ContentType.tweet;
    }
  }
}

extension ChangeTypeExtension on ChangeType {
  String get displayName {
    switch (this) {
      case ChangeType.create:
        return 'Created';
      case ChangeType.edit:
        return 'Edited';
      case ChangeType.delete:
        return 'Deleted';
      case ChangeType.move:
        return 'Moved';
      case ChangeType.comment:
        return 'Commented';
      case ChangeType.share:
        return 'Shared';
      case ChangeType.invite:
        return 'Invited';
      case ChangeType.permission:
        return 'Permission Changed';
    }
  }

  String get icon {
    switch (this) {
      case ChangeType.create:
        return '➕';
      case ChangeType.edit:
        return '✏️';
      case ChangeType.delete:
        return '🗑️';
      case ChangeType.move:
        return '🔄';
      case ChangeType.comment:
        return '💬';
      case ChangeType.share:
        return '🔗';
      case ChangeType.invite:
        return '👥';
      case ChangeType.permission:
        return '🔐';
    }
  }

  static ChangeType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'create':
        return ChangeType.create;
      case 'edit':
        return ChangeType.edit;
      case 'delete':
        return ChangeType.delete;
      case 'move':
        return ChangeType.move;
      case 'comment':
        return ChangeType.comment;
      case 'share':
        return ChangeType.share;
      case 'invite':
        return ChangeType.invite;
      case 'permission':
        return ChangeType.permission;
      default:
        return ChangeType.edit;
    }
  }
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.error:
        return 'Error';
    }
  }

  String get color {
    switch (this) {
      case SyncStatus.synced:
        return '#28a745'; // Green
      case SyncStatus.pending:
        return '#ffc107'; // Yellow
      case SyncStatus.conflict:
        return '#fd7e14'; // Orange
      case SyncStatus.error:
        return '#dc3545'; // Red
    }
  }

  static SyncStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'conflict':
        return SyncStatus.conflict;
      case 'error':
        return SyncStatus.error;
      default:
        return SyncStatus.pending;
    }
  }
}

extension PresenceStatusExtension on PresenceStatus {
  String get displayName {
    switch (this) {
      case PresenceStatus.online:
        return 'Online';
      case PresenceStatus.away:
        return 'Away';
      case PresenceStatus.busy:
        return 'Busy';
      case PresenceStatus.offline:
        return 'Offline';
    }
  }

  String get color {
    switch (this) {
      case PresenceStatus.online:
        return '#28a745'; // Green
      case PresenceStatus.away:
        return '#ffc107'; // Yellow
      case PresenceStatus.busy:
        return '#fd7e14'; // Orange
      case PresenceStatus.offline:
        return '#6c757d'; // Gray
    }
  }

  String get icon {
    switch (this) {
      case PresenceStatus.online:
        return '🟢';
      case PresenceStatus.away:
        return '🟡';
      case PresenceStatus.busy:
        return '🟠';
      case PresenceStatus.offline:
        return '⚫';
    }
  }

  static PresenceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return PresenceStatus.online;
      case 'away':
        return PresenceStatus.away;
      case 'busy':
        return PresenceStatus.busy;
      case 'offline':
        return PresenceStatus.offline;
      default:
        return PresenceStatus.offline;
    }
  }
}

class CollaborationMember {
  final String id;
  final String userId;
  final String displayName;
  final String? email;
  final String? avatar;
  final CollaborationRole role;
  final CollaborationStatus status;
  final List<CollaborationPermission> permissions;
  final DateTime joinedAt;
  final DateTime? lastActive;
  final PresenceStatus presenceStatus;
  final bool isOnline;
  final String? currentDocument;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  
  CollaborationMember({
    required this.id,
    required this.userId,
    required this.displayName,
    this.email,
    this.avatar,
    required this.role,
    required this.status,
    required this.permissions,
    required this.joinedAt,
    this.lastActive,
    this.presenceStatus = PresenceStatus.offline,
    this.isOnline = false,
    this.currentDocument,
    this.metadata = const {},
    this.tags = const [],
  });
  
  factory CollaborationMember.fromJson(Map<String, dynamic> json) {
    final permissions = <CollaborationPermission>[];
    if (json['permissions'] != null) {
      final permissionsList = json['permissions'] as List;
      for (final permission in permissionsList) {
        permissions.add(CollaborationPermissionExtension.fromString(permission));
      }
    }
    
    return CollaborationMember(
      id: json['id'],
      userId: json['userId'],
      displayName: json['displayName'],
      email: json['email'],
      avatar: json['avatar'],
      role: CollaborationRoleExtension.fromString(json['role']),
      status: CollaborationStatusExtension.fromString(json['status']),
      permissions: permissions,
      joinedAt: DateTime.parse(json['joinedAt']),
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
      presenceStatus: PresenceStatusExtension.fromString(json['presenceStatus'] ?? 'offline'),
      isOnline: json['isOnline'] ?? false,
      currentDocument: json['currentDocument'],
      metadata: json['metadata'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'avatar': avatar,
      'role': role.name,
      'status': status.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'joinedAt': joinedAt.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
      'presenceStatus': presenceStatus.name,
      'isOnline': isOnline,
      'currentDocument': currentDocument,
      'metadata': metadata,
      'tags': tags,
    };
  }
  
  bool get isActive => status == CollaborationStatus.active;
  
  bool get canEdit => permissions.contains(CollaborationPermission.edit);
  
  bool get canDelete => permissions.contains(CollaborationPermission.delete);
  
  bool get canShare => permissions.contains(CollaborationPermission.share);
  
  bool get canInvite => permissions.contains(CollaborationPermission.invite);
  
  bool get canManage => permissions.contains(CollaborationPermission.manage);
  
  bool get isOwner => role == CollaborationRole.owner;
  
  bool get isAdmin => role == CollaborationRole.admin;
  
  bool get isEditor => role == CollaborationRole.editor;
  
  bool get isViewer => role == CollaborationRole.viewer;
  
  bool get isCommenter => role == CollaborationRole.commenter;
  
  String get timeAgo {
    if (lastActive == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    
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
  
  void updatePresence(PresenceStatus newStatus) {
    presenceStatus = newStatus;
    isOnline = newStatus == PresenceStatus.online;
    lastActive = DateTime.now();
  }
  
  void updateRole(CollaborationRole newRole) {
    role = newRole;
    permissions = newRole.permissions;
  }
  
  bool hasPermission(CollaborationPermission permission) {
    return permissions.contains(permission);
  }
}
