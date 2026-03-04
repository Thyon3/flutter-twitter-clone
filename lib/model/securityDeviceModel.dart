import 'package:twitterclone/model/securityModel.dart';

class SecurityDevice {
  final String id;
  final String userId;
  final String deviceId;
  final String? name;
  final String? type;
  final String? platform;
  final String? browser;
  final String? version;
  final DeviceTrustLevel trustLevel;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final String? ipAddress;
  final String? location;
  final bool isActive;
  final bool isCurrent;
  final Map<String, dynamic> metadata;
  final List<DeviceFingerprint> fingerprints;
  final List<SecuritySession> sessions;
  final int loginCount;
  final DateTime? lastLoginAt;
  final bool isBlocked;
  final DateTime? blockedAt;
  final String? blockedReason;
  final List<String> notifications;
  
  SecurityDevice({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.name,
    this.type,
    this.platform,
    this.browser,
    this.version,
    required this.trustLevel,
    required this.firstSeen,
    required this.lastSeen,
    this.ipAddress,
    this.location,
    this.isActive = true,
    this.isCurrent = false,
    this.metadata = const {},
    this.fingerprints = const [],
    this.sessions = const [],
    this.loginCount = 0,
    this.lastLoginAt,
    this.isBlocked = false,
    this.blockedAt,
    this.blockedReason,
    this.notifications = const [],
  });
  
  factory SecurityDevice.fromJson(Map<String, dynamic> json) {
    final fingerprints = <DeviceFingerprint>[];
    if (json['fingerprints'] != null) {
      final fingerprintsList = json['fingerprints'] as List;
      for (final fingerprint in fingerprintsList) {
        fingerprints.add(DeviceFingerprint.fromJson(fingerprint));
      }
    }
    
    final sessions = <SecuritySession>[];
    if (json['sessions'] != null) {
      final sessionsList = json['sessions'] as List;
      for (final session in sessionsList) {
        sessions.add(SecuritySession.fromJson(session));
      }
    }
    
    return SecurityDevice(
      id: json['id'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      name: json['name'],
      type: json['type'],
      platform: json['platform'],
      browser: json['browser'],
      version: json['version'],
      trustLevel: DeviceTrustLevelExtension.fromString(json['trustLevel']),
      firstSeen: DateTime.parse(json['firstSeen']),
      lastSeen: DateTime.parse(json['lastSeen']),
      ipAddress: json['ipAddress'],
      location: json['location'],
      isActive: json['isActive'] ?? true,
      isCurrent: json['isCurrent'] ?? false,
      metadata: json['metadata'] ?? {},
      fingerprints: fingerprints,
      sessions: sessions,
      loginCount: json['loginCount'] ?? 0,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      isBlocked: json['isBlocked'] ?? false,
      blockedAt: json['blockedAt'] != null ? DateTime.parse(json['blockedAt']) : null,
      blockedReason: json['blockedReason'],
      notifications: List<String>.from(json['notifications'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceId': deviceId,
      'name': name,
      'type': type,
      'platform': platform,
      'browser': browser,
      'version': version,
      'trustLevel': trustLevel.name,
      'firstSeen': firstSeen.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'ipAddress': ipAddress,
      'location': location,
      'isActive': isActive,
      'isCurrent': isCurrent,
      'metadata': metadata,
      'fingerprints': fingerprints.map((f) => f.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'loginCount': loginCount,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isBlocked': isBlocked,
      'blockedAt': blockedAt?.toIso8601String(),
      'blockedReason': blockedReason,
      'notifications': notifications,
    };
  }
  
  bool get isTrusted => trustLevel == DeviceTrustLevel.trusted;
  
  bool get isUnknown => trustLevel == DeviceTrustLevel.unknown;
  
  bool get isUntrusted => trustLevel == DeviceTrustLevel.untrusted;
  
  bool get isMobile => type?.toLowerCase().contains('mobile') ?? false;
  
  bool get isTablet => type?.toLowerCase().contains('tablet') ?? false;
  
  bool get isDesktop => !isMobile && !isTablet;
  
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (platform != null && browser != null) {
      return '$platform - $browser';
    }
    if (platform != null) return platform!;
    return 'Unknown Device';
  }
  
  String get icon {
    if (isMobile) return '📱';
    if (isTablet) return '📱';
    if (isDesktop) return '💻';
    return '🖥️';
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
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
  
  String get firstSeenAgo {
    final now = DateTime.now();
    final difference = now.difference(firstSeen);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
  
  void updateLastSeen() {
    lastSeen = DateTime.now();
    loginCount++;
    lastLoginAt = DateTime.now();
  }
  
  void setTrustLevel(DeviceTrustLevel newLevel) {
    trustLevel = newLevel;
  }
  
  void block(String reason) {
    isBlocked = true;
    blockedAt = DateTime.now();
    blockedReason = reason;
    isActive = false;
  }
  
  void unblock() {
    isBlocked = false;
    blockedAt = null;
    blockedReason = null;
    isActive = true;
  }
  
  void addNotification(String notification) {
    notifications.add(notification);
  }
  
  void addFingerprint(DeviceFingerprint fingerprint) {
    if (!fingerprints.any((f) => f.hash == fingerprint.hash)) {
      fingerprints.add(fingerprint);
    }
  }
  
  void addSession(SecuritySession session) {
    sessions.add(session);
  }
  
  bool matchesFingerprint(String hash) {
    return fingerprints.any((f) => f.hash == hash);
  }
  
  List<SecuritySession> getActiveSessions() {
    return sessions.where((s) => s.isActive).toList();
  }
  
  int get activeSessionCount => getActiveSessions().length;
  
  bool hasRecentActivity() {
    final now = DateTime.now();
    return now.difference(lastSeen).inDays < 7;
  }
}

class DeviceFingerprint {
  final String id;
  final String hash;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool isActive;
  
  DeviceFingerprint({
    required this.id,
    required this.hash,
    required this.type,
    required this.createdAt,
    required this.data,
    this.isActive = true,
  });
  
  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) {
    return DeviceFingerprint(
      id: json['id'],
      hash: json['hash'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] ?? {},
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hash': hash,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
      'isActive': isActive,
    };
  }
  
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
