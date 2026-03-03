import 'package:twitterclone/model/collaborationModel.dart';

class RealtimePresence {
  final String userId;
  final String? documentId;
  final String? projectId;
  final PresenceStatus status;
  final String? statusMessage;
  final DateTime lastSeen;
  final Map<String, dynamic> metadata;
  final UserActivity? currentActivity;
  final List<String> activeSessions;
  final DeviceInfo? deviceInfo;
  final LocationInfo? locationInfo;
  
  RealtimePresence({
    required this.userId,
    this.documentId,
    this.projectId,
    required this.status,
    this.statusMessage,
    required this.lastSeen,
    this.metadata = const {},
    this.currentActivity,
    this.activeSessions = const [],
    this.deviceInfo,
    this.locationInfo,
  });
  
  factory RealtimePresence.fromJson(Map<String, dynamic> json) {
    return RealtimePresence(
      userId: json['userId'],
      documentId: json['documentId'],
      projectId: json['projectId'],
      status: PresenceStatusExtension.fromString(json['status']),
      statusMessage: json['statusMessage'],
      lastSeen: DateTime.parse(json['lastSeen']),
      metadata: json['metadata'] ?? {},
      currentActivity: json['currentActivity'] != null ? UserActivity.fromJson(json['currentActivity']) : null,
      activeSessions: List<String>.from(json['activeSessions'] ?? []),
      deviceInfo: json['deviceInfo'] != null ? DeviceInfo.fromJson(json['deviceInfo']) : null,
      locationInfo: json['locationInfo'] != null ? LocationInfo.fromJson(json['locationInfo']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'documentId': documentId,
      'projectId': projectId,
      'status': status.name,
      'statusMessage': statusMessage,
      'lastSeen': lastSeen.toIso8601String(),
      'metadata': metadata,
      'currentActivity': currentActivity?.toJson(),
      'activeSessions': activeSessions,
      'deviceInfo': deviceInfo?.toJson(),
      'locationInfo': locationInfo?.toJson(),
    };
  }
  
  bool get isOnline => status == PresenceStatus.online;
  
  bool get isAway => status == PresenceStatus.away;
  
  bool get isBusy => status == PresenceStatus.busy;
  
  bool get isOffline => status == PresenceStatus.offline;
  
  bool get isActive => currentActivity != null;
  
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
  
  void updateStatus(PresenceStatus newStatus, {String? message}) {
    status = newStatus;
    statusMessage = message;
    lastSeen = DateTime.now();
  }
  
  void setActivity(UserActivity activity) {
    currentActivity = activity;
    lastSeen = DateTime.now();
  }
  
  void clearActivity() {
    currentActivity = null;
  }
}

class UserActivity {
  final String type;
  final String? targetId;
  final String? targetType;
  final String description;
  final DateTime startedAt;
  final Map<String, dynamic> data;
  
  UserActivity({
    required this.type,
    this.targetId,
    this.targetType,
    required this.description,
    required this.startedAt,
    this.data = const {},
  });
  
  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      type: json['type'],
      targetId: json['targetId'],
      targetType: json['targetType'],
      description: json['description'],
      startedAt: DateTime.parse(json['startedAt']),
      data: json['data'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'targetId': targetId,
      'targetType': targetType,
      'description': description,
      'startedAt': startedAt.toIso8601String(),
      'data': data,
    };
  }
  
  String get duration {
    final now = DateTime.now();
    final difference = now.difference(startedAt);
    
    if (difference.inMinutes < 1) {
      return 'Just started';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class DeviceInfo {
  final String deviceId;
  final String deviceType;
  final String platform;
  final String browser;
  final String version;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final String? userAgent;
  
  DeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.platform,
    required this.browser,
    required this.version,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    this.userAgent,
  });
  
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'],
      deviceType: json['deviceType'],
      platform: json['platform'],
      browser: json['browser'],
      version: json['version'],
      isMobile: json['isMobile'],
      isTablet: json['isTablet'],
      isDesktop: json['isDesktop'],
      userAgent: json['userAgent'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'platform': platform,
      'browser': browser,
      'version': version,
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
      'userAgent': userAgent,
    };
  }
  
  String get displayName {
    if (isMobile) return '📱 $platform';
    if (isTablet) return '📱 $platform (Tablet)';
    return '💻 $platform';
  }
}

class LocationInfo {
  final String? country;
  final String? region;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? timezone;
  final DateTime? detectedAt;
  final bool isPrecise;
  
  LocationInfo({
    this.country,
    this.region,
    this.city,
    this.latitude,
    this.longitude,
    this.timezone,
    this.detectedAt,
    this.isPrecise = false,
  });
  
  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      country: json['country'],
      region: json['region'],
      city: json['city'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timezone: json['timezone'],
      detectedAt: json['detectedAt'] != null ? DateTime.parse(json['detectedAt']) : null,
      isPrecise: json['isPrecise'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'region': region,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'detectedAt': detectedAt?.toIso8601String(),
      'isPrecise': isPrecise,
    };
  }
  
  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (country != null) {
      return country!;
    } else if (isPrecise) {
      return 'Location available';
    } else {
      return 'Location approximate';
    }
  }
  
  String get flag {
    if (country == null) return '🌍';
    
    final flags = {
      'US': '🇺🇸',
      'GB': '🇬🇧',
      'CA': '🇨🇦',
      'AU': '🇦🇺',
      'DE': '🇩🇪',
      'FR': '🇫🇷',
      'JP': '🇯🇵',
      'CN': '🇨🇳',
      'IN': '🇮🇳',
      'BR': '🇧🇷',
      'MX': '🇲🇽',
      'ES': '🇪🇸',
      'IT': '🇮🇹',
      'RU': '🇷🇺',
      'KR': '🇰🇷',
      'NL': '🇳🇱',
      'SE': '🇸🇪',
      'NO': '🇳🇴',
      'DK': '🇩🇰',
      'FI': '🇫🇮',
      'PL': '🇵🇱',
      'TR': '🇹🇷',
      'ZA': '🇿🇦',
      'EG': '🇪🇬',
      'SA': '🇸🇦',
      'AE': '🇦🇪',
      'IL': '🇮🇱',
      'TH': '🇹🇭',
      'SG': '🇸🇬',
      'MY': '🇲🇾',
      'PH': '🇵🇭',
      'ID': '🇮🇩',
      'VN': '🇻🇳',
      'AR': '🇦🇷',
      'CL': '🇨🇱',
      'CO': '🇨🇴',
      'PE': '🇵🇪',
      'VE': '🇻🇪',
      'UY': '🇺🇾',
      'NZ': '🇳🇿',
    };
    
    return flags[country!.toUpperCase()] ?? '🌍';
  }
}

class PresenceEvent {
  final String id;
  final String userId;
  final PresenceEventType eventType;
  final Map<String, dynamic>? eventData;
  final DateTime timestamp;
  final String? source;
  final Map<String, dynamic> metadata;
  
  PresenceEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    this.eventData,
    required this.timestamp,
    this.source,
    this.metadata = const {},
  });
  
  factory PresenceEvent.fromJson(Map<String, dynamic> json) {
    return PresenceEvent(
      id: json['id'],
      userId: json['userId'],
      eventType: PresenceEventTypeExtension.fromString(json['eventType']),
      eventData: json['eventData'],
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'],
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType.name,
      'eventData': eventData,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
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

enum PresenceEventType {
  online,
  offline,
  away,
  busy,
  typing,
  stoppedTyping,
  joinedDocument,
  leftDocument,
  joinedProject,
  leftProject,
}

extension PresenceEventTypeExtension on PresenceEventType {
  String get displayName {
    switch (this) {
      case PresenceEventType.online:
        return 'Came Online';
      case PresenceEventType.offline:
        return 'Went Offline';
      case PresenceEventType.away:
        return 'Went Away';
      case PresenceEventType.busy:
        return 'Set Busy';
      case PresenceEventType.typing:
        return 'Started Typing';
      case PresenceEventType.stoppedTyping:
        return 'Stopped Typing';
      case PresenceEventType.joinedDocument:
        return 'Joined Document';
      case PresenceEventType.leftDocument:
        return 'Left Document';
      case PresenceEventType.joinedProject:
        return 'Joined Project';
      case PresenceEventType.leftProject:
        return 'Left Project';
    }
  }
  
  String get icon {
    switch (this) {
      case PresenceEventType.online:
        return '🟢';
      case PresenceEventType.offline:
        return '🔴';
      case PresenceEventType.away:
        return '🟡';
      case PresenceEventType.busy:
        return '🟠';
      case PresenceEventType.typing:
        return '⌨️';
      case PresenceEventType.stoppedTyping:
        return '✋';
      case PresenceEventType.joinedDocument:
        return '📄';
      case PresenceEventType.leftDocument:
        return '📤';
      case PresenceEventType.joinedProject:
        return '📁';
      case PresenceEventType.leftProject:
        return '📂';
    }
  }
  
  static PresenceEventType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'online':
        return PresenceEventType.online;
      case 'offline':
        return PresenceEventType.offline;
      case 'away':
        return PresenceEventType.away;
      case 'busy':
        return PresenceEventType.busy;
      case 'typing':
        return PresenceEventType.typing;
      case 'stoppedtyping':
        return PresenceEventType.stoppedTyping;
      case 'joineddocument':
        return PresenceEventType.joinedDocument;
      case 'leftdocument':
        return PresenceEventType.leftDocument;
      case 'joinedproject':
        return PresenceEventType.joinedProject;
      case 'leftproject':
        return PresenceEventType.leftProject;
      default:
        return PresenceEventType.online;
    }
  }
}
