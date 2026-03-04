import 'package:twitterclone/model/securityModel.dart';

class SecurityThreat {
  final String id;
  final ThreatType type;
  final SecurityLevel severity;
  final String? title;
  final String description;
  final String? userId;
  final String? sessionId;
  final String? deviceId;
  final String? ipAddress;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final bool isActive;
  final bool isResolved;
  final String? resolvedBy;
  final List<ThreatIndicator> indicators;
  final Map<String, dynamic> evidence;
  final List<String> affectedResources;
  final SecurityAction? recommendedAction;
  final SecurityAction? actionTaken;
  final String? actionReason;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  
  SecurityThreat({
    required this.id,
    required this.type,
    required this.severity,
    this.title,
    required this.description,
    this.userId,
    this.sessionId,
    this.deviceId,
    this.ipAddress,
    required this.detectedAt,
    this.resolvedAt,
    this.isActive = true,
    this.isResolved = false,
    this.resolvedBy,
    this.indicators = const [],
    this.evidence = const {},
    this.affectedResources = const [],
    this.recommendedAction,
    this.actionTaken,
    this.actionReason,
    this.tags = const [],
    this.metadata = const {},
  });
  
  factory SecurityThreat.fromJson(Map<String, dynamic> json) {
    final indicators = <ThreatIndicator>[];
    if (json['indicators'] != null) {
      final indicatorsList = json['indicators'] as List;
      for (final indicator in indicatorsList) {
        indicators.add(ThreatIndicator.fromJson(indicator));
      }
    }
    
    return SecurityThreat(
      id: json['id'],
      type: ThreatTypeExtension.fromString(json['type']),
      severity: SecurityLevelExtension.fromString(json['severity']),
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      deviceId: json['deviceId'],
      ipAddress: json['ipAddress'],
      detectedAt: DateTime.parse(json['detectedAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      isActive: json['isActive'] ?? true,
      isResolved: json['isResolved'] ?? false,
      resolvedBy: json['resolvedBy'],
      indicators: indicators,
      evidence: json['evidence'] ?? {},
      affectedResources: List<String>.from(json['affectedResources'] ?? []),
      recommendedAction: json['recommendedAction'] != null ? SecurityActionExtension.fromString(json['recommendedAction']) : null,
      actionTaken: json['actionTaken'] != null ? SecurityActionExtension.fromString(json['actionTaken']) : null,
      actionReason: json['actionReason'],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'title': title,
      'description': description,
      'userId': userId,
      'sessionId': sessionId,
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'detectedAt': detectedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'isActive': isActive,
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'evidence': evidence,
      'affectedResources': affectedResources,
      'recommendedAction': recommendedAction?.name,
      'actionTaken': actionTaken?.name,
      'actionReason': actionReason,
      'tags': tags,
      'metadata': metadata,
    };
  }
  
  bool get isCritical => severity == SecurityLevel.critical;
  
  bool get isHighRisk => severity == SecurityLevel.high || severity == SecurityLevel.critical;
  
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(detectedAt).inHours < 24;
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(detectedAt);
    
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
    isActive = false;
    resolvedAt = DateTime.now();
    this.resolvedBy = resolvedBy;
    actionTaken = action;
    actionReason = reason;
  }
  
  void addIndicator(ThreatIndicator indicator) {
    indicators.add(indicator);
  }
  
  void addEvidence(String key, dynamic value) {
    evidence[key] = value;
  }
  
  void addAffectedResource(String resource) {
    if (!affectedResources.contains(resource)) {
      affectedResources.add(resource);
    }
  }
  
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }
  
  bool hasTag(String tag) {
    return tags.contains(tag);
  }
  
  double get confidenceScore {
    if (indicators.isEmpty) return 0.0;
    final totalConfidence = indicators.fold(0.0, (sum, indicator) => sum + indicator.confidence);
    return totalConfidence / indicators.length;
  }
  
  String get riskScore {
    final score = confidenceScore * severity.index;
    if (score >= 3.0) return 'Critical';
    if (score >= 2.0) return 'High';
    if (score >= 1.0) return 'Medium';
    return 'Low';
  }
}

class ThreatIndicator {
  final String id;
  final String type;
  final String description;
  final double confidence;
  final DateTime detectedAt;
  final Map<String, dynamic> data;
  final bool isActive;
  
  ThreatIndicator({
    required this.id,
    required this.type,
    required this.description,
    required this.confidence,
    required this.detectedAt,
    this.data = const {},
    this.isActive = true,
  });
  
  factory ThreatIndicator.fromJson(Map<String, dynamic> json) {
    return ThreatIndicator(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt']),
      data: json['data'] ?? {},
      isActive: json['isActive'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'confidence': confidence,
      'detectedAt': detectedAt.toIso8601String(),
      'data': data,
      'isActive': isActive,
    };
  }
  
  String get confidenceLevel {
    if (confidence >= 0.8) return 'Very High';
    if (confidence >= 0.6) return 'High';
    if (confidence >= 0.4) return 'Medium';
    if (confidence >= 0.2) return 'Low';
    return 'Very Low';
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(detectedAt);
    
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

class ThreatPattern {
  final String id;
  final String name;
  final String description;
  final ThreatType type;
  final List<String> indicatorTypes;
  final Map<String, dynamic> pattern;
  final double threshold;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggerCount;
  
  ThreatPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.indicatorTypes,
    required this.pattern,
    required this.threshold,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount = 0,
  });
  
  factory ThreatPattern.fromJson(Map<String, dynamic> json) {
    return ThreatPattern(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ThreatTypeExtension.fromString(json['type']),
      indicatorTypes: List<String>.from(json['indicatorTypes'] ?? []),
      pattern: json['pattern'] ?? {},
      threshold: (json['threshold'] as num).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null ? DateTime.parse(json['lastTriggered']) : null,
      triggerCount: json['triggerCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'indicatorTypes': indicatorTypes,
      'pattern': pattern,
      'threshold': threshold,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'triggerCount': triggerCount,
    };
  }
  
  bool matches(List<ThreatIndicator> indicators) {
    if (!isActive) return false;
    
    final matchingIndicators = indicators.where((indicator) =>
      indicatorTypes.contains(indicator.type) && indicator.isActive
    ).toList();
    
    if (matchingIndicators.isEmpty) return false;
    
    final totalConfidence = matchingIndicators
        .fold(0.0, (sum, indicator) => sum + indicator.confidence);
    
    return totalConfidence / matchingIndicators.length >= threshold;
  }
  
  void recordTrigger() {
    lastTriggered = DateTime.now();
    triggerCount++;
  }
  
  String get timeSinceLastTrigger {
    if (lastTriggered == null) return 'Never triggered';
    
    final now = DateTime.now();
    final difference = now.difference(lastTriggered!);
    
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
