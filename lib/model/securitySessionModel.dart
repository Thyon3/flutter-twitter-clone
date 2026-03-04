import 'package:twitterclone/model/securityModel.dart';

class SecuritySession {
  final String id;
  final String userId;
  final String sessionId;
  final AuthenticationMethod authMethod;
  final SessionStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastActivity;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceId;
  final String? location;
  final Map<String, dynamic> metadata;
  final List<String> permissions;
  final bool isCurrent;
  final bool isTrusted;
  final SecurityLevel riskLevel;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final List<SessionEvent> events;
  
  SecuritySession({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.authMethod,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.lastActivity,
    this.ipAddress,
    this.userAgent,
    this.deviceId,
    this.location,
    this.metadata = const {},
    this.permissions = const [],
    this.isCurrent = false,
    this.isTrusted = false,
    this.riskLevel = SecurityLevel.low,
    this.failedAttempts = 0,
    this.lockedUntil,
    this.events = const [],
  });
  
  factory SecuritySession.fromJson(Map<String, dynamic> json) {
    final events = <SessionEvent>[];
    if (json['events'] != null) {
      final eventsList = json['events'] as List;
      for (final event in eventsList) {
        events.add(SessionEvent.fromJson(event));
      }
    }
    
    return SecuritySession(
      id: json['id'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      authMethod: AuthenticationMethodExtension.fromString(json['authMethod']),
      status: SessionStatusExtension.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      lastActivity: json['lastActivity'] != null ? DateTime.parse(json['lastActivity']) : null,
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      deviceId: json['deviceId'],
      location: json['location'],
      metadata: json['metadata'] ?? {},
      permissions: List<String>.from(json['permissions'] ?? []),
      isCurrent: json['isCurrent'] ?? false,
      isTrusted: json['isTrusted'] ?? false,
      riskLevel: SecurityLevelExtension.fromString(json['riskLevel'] ?? 'low'),
      failedAttempts: json['failedAttempts'] ?? 0,
      lockedUntil: json['lockedUntil'] != null ? DateTime.parse(json['lockedUntil']) : null,
      events: events,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'authMethod': authMethod.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'lastActivity': lastActivity?.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'deviceId': deviceId,
      'location': location,
      'metadata': metadata,
      'permissions': permissions,
      'isCurrent': isCurrent,
      'isTrusted': isTrusted,
      'riskLevel': riskLevel.name,
      'failedAttempts': failedAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
  
  bool get isActive => status == SessionStatus.active;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool get isLocked => lockedUntil != null && DateTime.now().isBefore(lockedUntil!);
  
  bool get isHighRisk => riskLevel == SecurityLevel.high || riskLevel == SecurityLevel.critical;
  
  bool get isCompromised => failedAttempts >= 3 || isHighRisk;
  
  Duration get timeRemaining {
    if (isExpired) return Duration.zero;
    return expiresAt.difference(DateTime.now());
  }
  
  String get timeRemainingDisplay {
    final remaining = timeRemaining;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
    } else {
      return '${remaining.inSeconds}s';
    }
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastActivity ?? createdAt);
    
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
  
  void extendSession(Duration extension) {
    expiresAt = expiresAt.add(extension);
  }
  
  void updateLastActivity() {
    lastActivity = DateTime.now();
  }
  
  void incrementFailedAttempts() {
    failedAttempts++;
    if (failedAttempts >= 3) {
      lockedUntil = DateTime.now().add(const Duration(minutes: 30));
      status = SessionStatus.suspended;
    }
  }
  
  void resetFailedAttempts() {
    failedAttempts = 0;
    lockedUntil = null;
    if (status == SessionStatus.suspended) {
      status = SessionStatus.active;
    }
  }
  
  void addPermission(String permission) {
    if (!permissions.contains(permission)) {
      permissions.add(permission);
    }
  }
  
  void removePermission(String permission) {
    permissions.remove(permission);
  }
  
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
  
  void addEvent(SessionEvent event) {
    events.add(event);
  }
  
  void terminate(String reason) {
    status = SessionStatus.terminated;
    addEvent(SessionEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'terminated',
      description: reason,
      timestamp: DateTime.now(),
    ));
  }
}

class SessionEvent {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  SessionEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });
  
  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    return SessionEvent(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
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
