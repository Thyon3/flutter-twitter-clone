enum SecurityLevel {
  low,
  medium,
  high,
  critical,
}

enum SecurityEventType {
  login,
  logout,
  passwordChange,
  emailChange,
  twoFactorEnabled,
  twoFactorDisabled,
  accountLocked,
  accountUnlocked,
  suspiciousActivity,
  securityAlert,
  dataBreach,
  deviceAdded,
  deviceRemoved,
  sessionExpired,
  permissionChange,
}

enum ThreatType {
  bruteForce,
  phishing,
  malware,
  suspiciousLogin,
  unusualActivity,
  dataExfiltration,
  accountTakeover,
  ddosAttack,
  sqlInjection,
  xssAttack,
  csrfAttack,
  socialEngineering,
}

enum AuthenticationMethod {
  password,
  twoFactor,
  biometric,
  social,
  sso,
  magicLink,
  deviceAuth,
}

enum SessionStatus {
  active,
  expired,
  terminated,
  suspended,
}

enum DeviceTrustLevel {
  trusted,
  unknown,
  untrusted,
  blocked,
}

enum SecurityAction {
  allow,
  block,
  warn,
  requireVerification,
  forceLogout,
  lockAccount,
  notifyAdmin,
  logOnly,
}

extension SecurityLevelExtension on SecurityLevel {
  String get displayName {
    switch (this) {
      case SecurityLevel.low:
        return 'Low';
      case SecurityLevel.medium:
        return 'Medium';
      case SecurityLevel.high:
        return 'High';
      case SecurityLevel.critical:
        return 'Critical';
    }
  }

  String get color {
    switch (this) {
      case SecurityLevel.low:
        return '#28a745'; // Green
      case SecurityLevel.medium:
        return '#ffc107'; // Yellow
      case SecurityLevel.high:
        return '#fd7e14'; // Orange
      case SecurityLevel.critical:
        return '#dc3545'; // Red
    }
  }

  String get icon {
    switch (this) {
      case SecurityLevel.low:
        return '🟢';
      case SecurityLevel.medium:
        return '🟡';
      case SecurityLevel.high:
        return '🟠';
      case SecurityLevel.critical:
        return '🔴';
    }
  }

  static SecurityLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return SecurityLevel.low;
      case 'medium':
        return SecurityLevel.medium;
      case 'high':
        return SecurityLevel.high;
      case 'critical':
        return SecurityLevel.critical;
      default:
        return SecurityLevel.medium;
    }
  }
}

extension SecurityEventTypeExtension on SecurityEventType {
  String get displayName {
    switch (this) {
      case SecurityEventType.login:
        return 'Login';
      case SecurityEventType.logout:
        return 'Logout';
      case SecurityEventType.passwordChange:
        return 'Password Changed';
      case SecurityEventType.emailChange:
        return 'Email Changed';
      case SecurityEventType.twoFactorEnabled:
        return '2FA Enabled';
      case SecurityEventType.twoFactorDisabled:
        return '2FA Disabled';
      case SecurityEventType.accountLocked:
        return 'Account Locked';
      case SecurityEventType.accountUnlocked:
        return 'Account Unlocked';
      case SecurityEventType.suspiciousActivity:
        return 'Suspicious Activity';
      case SecurityEventType.securityAlert:
        return 'Security Alert';
      case SecurityEventType.dataBreach:
        return 'Data Breach';
      case SecurityEventType.deviceAdded:
        return 'Device Added';
      case SecurityEventType.deviceRemoved:
        return 'Device Removed';
      case SecurityEventType.sessionExpired:
        return 'Session Expired';
      case SecurityEventType.permissionChange:
        return 'Permission Changed';
    }
  }

  String get icon {
    switch (this) {
      case SecurityEventType.login:
        return '🔑';
      case SecurityEventType.logout:
        return '🚪';
      case SecurityEventType.passwordChange:
        return '🔐';
      case SecurityEventType.emailChange:
        return '📧';
      case SecurityEventType.twoFactorEnabled:
        return '🛡️';
      case SecurityEventType.twoFactorDisabled:
        return '⚠️';
      case SecurityEventType.accountLocked:
        return '🔒';
      case SecurityEventType.accountUnlocked:
        return '🔓';
      case SecurityEventType.suspiciousActivity:
        return '🚨';
      case SecurityEventType.securityAlert:
        return '⚡';
      case SecurityEventType.dataBreach:
        return '💥';
      case SecurityEventType.deviceAdded:
        return '📱';
      case SecurityEventType.deviceRemoved:
        return '🗑️';
      case SecurityEventType.sessionExpired:
        return '⏰';
      case SecurityEventType.permissionChange:
        return '👥';
    }
  }

  bool get isCritical {
    switch (this) {
      case SecurityEventType.dataBreach:
      case SecurityEventType.accountLocked:
      case SecurityEventType.suspiciousActivity:
        return true;
      default:
        return false;
    }
  }

  static SecurityEventType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'login':
        return SecurityEventType.login;
      case 'logout':
        return SecurityEventType.logout;
      case 'passwordchange':
        return SecurityEventType.passwordChange;
      case 'emailchange':
        return SecurityEventType.emailChange;
      case 'twofactorenabled':
        return SecurityEventType.twoFactorEnabled;
      case 'twofactordisabled':
        return SecurityEventType.twoFactorDisabled;
      case 'accountlocked':
        return SecurityEventType.accountLocked;
      case 'accountunlocked':
        return SecurityEventType.accountUnlocked;
      case 'suspiciousactivity':
        return SecurityEventType.suspiciousActivity;
      case 'securityalert':
        return SecurityEventType.securityAlert;
      case 'databreach':
        return SecurityEventType.dataBreach;
      case 'deviceadded':
        return SecurityEventType.deviceAdded;
      case 'deviceremoved':
        return SecurityEventType.deviceRemoved;
      case 'sessionexpired':
        return SecurityEventType.sessionExpired;
      case 'permissionchange':
        return SecurityEventType.permissionChange;
      default:
        return SecurityEventType.login;
    }
  }
}

extension ThreatTypeExtension on ThreatType {
  String get displayName {
    switch (this) {
      case ThreatType.bruteForce:
        return 'Brute Force';
      case ThreatType.phishing:
        return 'Phishing';
      case ThreatType.malware:
        return 'Malware';
      case ThreatType.suspiciousLogin:
        return 'Suspicious Login';
      case ThreatType.unusualActivity:
        return 'Unusual Activity';
      case ThreatType.dataExfiltration:
        return 'Data Exfiltration';
      case ThreatType.accountTakeover:
        return 'Account Takeover';
      case ThreatType.ddosAttack:
        return 'DDoS Attack';
      case ThreatType.sqlInjection:
        return 'SQL Injection';
      case ThreatType.xssAttack:
        return 'XSS Attack';
      case ThreatType.csrfAttack:
        return 'CSRF Attack';
      case ThreatType.socialEngineering:
        return 'Social Engineering';
    }
  }

  String get severity {
    switch (this) {
      case ThreatType.bruteForce:
      case ThreatType.phishing:
      case ThreatType.accountTakeover:
        return 'Critical';
      case ThreatType.malware:
      case ThreatType.dataExfiltration:
      case ThreatType.ddosAttack:
        return 'High';
      case ThreatType.suspiciousLogin:
      case ThreatType.sqlInjection:
      case ThreatType.xssAttack:
      case ThreatType.csrfAttack:
        return 'Medium';
      case ThreatType.unusualActivity:
      case ThreatType.socialEngineering:
        return 'Low';
    }
  }

  String get icon {
    switch (this) {
      case ThreatType.bruteForce:
        return '🔨';
      case ThreatType.phishing:
        return '🎣';
      case ThreatType.malware:
        return '🦠';
      case ThreatType.suspiciousLogin:
        return '🔍';
      case ThreatType.unusualActivity:
        return '❓';
      case ThreatType.dataExfiltration:
        return '💾';
      case ThreatType.accountTakeover:
        return '👤';
      case ThreatType.ddosAttack:
        return '🌐';
      case ThreatType.sqlInjection:
        return '💉';
      case ThreatType.xssAttack:
        return '🎯';
      case ThreatType.csrfAttack:
        return '🔄';
      case ThreatType.socialEngineering:
        return '🗣️';
    }
  }

  static ThreatType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'bruteforce':
        return ThreatType.bruteForce;
      case 'phishing':
        return ThreatType.phishing;
      case 'malware':
        return ThreatType.malware;
      case 'suspiciouslogin':
        return ThreatType.suspiciousLogin;
      case 'unusualactivity':
        return ThreatType.unusualActivity;
      case 'dataexfiltration':
        return ThreatType.dataExfiltration;
      case 'accounttakeover':
        return ThreatType.accountTakeover;
      case 'ddosattack':
        return ThreatType.ddosAttack;
      case 'sqlinjection':
        return ThreatType.sqlInjection;
      case 'xssattack':
        return ThreatType.xssAttack;
      case 'csrfattack':
        return ThreatType.csrfAttack;
      case 'socialengineering':
        return ThreatType.socialEngineering;
      default:
        return ThreatType.suspiciousLogin;
    }
  }
}

extension AuthenticationMethodExtension on AuthenticationMethod {
  String get displayName {
    switch (this) {
      case AuthenticationMethod.password:
        return 'Password';
      case AuthenticationMethod.twoFactor:
        return 'Two-Factor';
      case AuthenticationMethod.biometric:
        return 'Biometric';
      case AuthenticationMethod.social:
        return 'Social';
      case AuthenticationMethod.sso:
        return 'SSO';
      case AuthenticationMethod.magicLink:
        return 'Magic Link';
      case AuthenticationMethod.deviceAuth:
        return 'Device Auth';
    }
  }

  String get icon {
    switch (this) {
      case AuthenticationMethod.password:
        return '🔑';
      case AuthenticationMethod.twoFactor:
        return '🔐';
      case AuthenticationMethod.biometric:
        return '👆';
      case AuthenticationMethod.social:
        return '🌐';
      case AuthenticationMethod.sso:
        return '🏢';
      case AuthenticationMethod.magicLink:
        return '✨';
      case AuthenticationMethod.deviceAuth:
        return '📱';
    }
  }

  static AuthenticationMethod fromString(String method) {
    switch (method.toLowerCase()) {
      case 'password':
        return AuthenticationMethod.password;
      case 'twofactor':
        return AuthenticationMethod.twoFactor;
      case 'biometric':
        return AuthenticationMethod.biometric;
      case 'social':
        return AuthenticationMethod.social;
      case 'sso':
        return AuthenticationMethod.sso;
      case 'magiclink':
        return AuthenticationMethod.magicLink;
      case 'deviceauth':
        return AuthenticationMethod.deviceAuth;
      default:
        return AuthenticationMethod.password;
    }
  }
}

extension SessionStatusExtension on SessionStatus {
  String get displayName {
    switch (this) {
      case SessionStatus.active:
        return 'Active';
      case SessionStatus.expired:
        return 'Expired';
      case SessionStatus.terminated:
        return 'Terminated';
      case SessionStatus.suspended:
        return 'Suspended';
    }
  }

  String get color {
    switch (this) {
      case SessionStatus.active:
        return '#28a745'; // Green
      case SessionStatus.expired:
        return '#6c757d'; // Gray
      case SessionStatus.terminated:
        return '#dc3545'; // Red
      case SessionStatus.suspended:
        return '#fd7e14'; // Orange
    }
  }

  static SessionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SessionStatus.active;
      case 'expired':
        return SessionStatus.expired;
      case 'terminated':
        return SessionStatus.terminated;
      case 'suspended':
        return SessionStatus.suspended;
      default:
        return SessionStatus.active;
    }
  }
}

extension DeviceTrustLevelExtension on DeviceTrustLevel {
  String get displayName {
    switch (this) {
      case DeviceTrustLevel.trusted:
        return 'Trusted';
      case DeviceTrustLevel.unknown:
        return 'Unknown';
      case DeviceTrustLevel.untrusted:
        return 'Untrusted';
      case DeviceTrustLevel.blocked:
        return 'Blocked';
    }
  }

  String get color {
    switch (this) {
      case DeviceTrustLevel.trusted:
        return '#28a745'; // Green
      case DeviceTrustLevel.unknown:
        return '#ffc107'; // Yellow
      case DeviceTrustLevel.untrusted:
        return '#fd7e14'; // Orange
      case DeviceTrustLevel.blocked:
        return '#dc3545'; // Red
    }
  }

  String get icon {
    switch (this) {
      case DeviceTrustLevel.trusted:
        return '✅';
      case DeviceTrustLevel.unknown:
        return '❓';
      case DeviceTrustLevel.untrusted:
        return '⚠️';
      case DeviceTrustLevel.blocked:
        return '🚫';
    }
  }

  static DeviceTrustLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'trusted':
        return DeviceTrustLevel.trusted;
      case 'unknown':
        return DeviceTrustLevel.unknown;
      case 'untrusted':
        return DeviceTrustLevel.untrusted;
      case 'blocked':
        return DeviceTrustLevel.blocked;
      default:
        return DeviceTrustLevel.unknown;
    }
  }
}

extension SecurityActionExtension on SecurityAction {
  String get displayName {
    switch (this) {
      case SecurityAction.allow:
        return 'Allow';
      case SecurityAction.block:
        return 'Block';
      case SecurityAction.warn:
        return 'Warn';
      case SecurityAction.requireVerification:
        return 'Require Verification';
      case SecurityAction.forceLogout:
        return 'Force Logout';
      case SecurityAction.lockAccount:
        return 'Lock Account';
      case SecurityAction.notifyAdmin:
        return 'Notify Admin';
      case SecurityAction.logOnly:
        return 'Log Only';
    }
  }

  static SecurityAction fromString(String action) {
    switch (action.toLowerCase()) {
      case 'allow':
        return SecurityAction.allow;
      case 'block':
        return SecurityAction.block;
      case 'warn':
        return SecurityAction.warn;
      case 'requireverification':
        return SecurityAction.requireVerification;
      case 'forcelogout':
        return SecurityAction.forceLogout;
      case 'lockaccount':
        return SecurityAction.lockAccount;
      case 'notifyadmin':
        return SecurityAction.notifyAdmin;
      case 'logonly':
        return SecurityAction.logOnly;
      default:
        return SecurityAction.allow;
    }
  }
}

class SecurityEvent {
  final String id;
  final String userId;
  final SecurityEventType eventType;
  final SecurityLevel severity;
  final String? description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceId;
  final String? location;
  final Map<String, dynamic> metadata;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final List<String> tags;
  final SecurityAction? actionTaken;
  final String? actionReason;
  
  SecurityEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.severity,
    this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.deviceId,
    this.location,
    this.metadata = const {},
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
    this.tags = const [],
    this.actionTaken,
    this.actionReason,
  });
  
  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'],
      userId: json['userId'],
      eventType: SecurityEventTypeExtension.fromString(json['eventType']),
      severity: SecurityLevelExtension.fromString(json['severity']),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      deviceId: json['deviceId'],
      location: json['location'],
      metadata: json['metadata'] ?? {},
      isResolved: json['isResolved'] ?? false,
      resolvedBy: json['resolvedBy'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      actionTaken: json['actionTaken'] != null ? SecurityActionExtension.fromString(json['actionTaken']) : null,
      actionReason: json['actionReason'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType.name,
      'severity': severity.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'deviceId': deviceId,
      'location': location,
      'metadata': metadata,
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'tags': tags,
      'actionTaken': actionTaken?.name,
      'actionReason': actionReason,
    };
  }
  
  bool get isCritical => severity == SecurityLevel.critical;
  
  bool get isHighRisk => severity == SecurityLevel.high || severity == SecurityLevel.critical;
  
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(timestamp).inHours < 24;
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
  
  void resolve(String resolvedBy, SecurityAction action, String? reason) {
    isResolved = true;
    this.resolvedBy = resolvedBy;
    resolvedAt = DateTime.now();
    actionTaken = action;
    actionReason = reason;
  }
  
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }
  
  bool hasTag(String tag) {
    return tags.contains(tag);
  }
}
