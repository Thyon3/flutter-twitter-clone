import 'package:twitterclone/model/moderationModel.dart';

enum FilterAction {
  block,
  flag,
  warn,
  quarantine,
  escalate,
  log,
}

enum FilterOperator {
  contains,
  equals,
  startsWith,
  endsWith,
  regex,
  greaterThan,
  lessThan,
  inList,
  notInList,
}

class ModerationFilterRule {
  final String id;
  final String name;
  final String description;
  final ModerationFilter filterType;
  final FilterAction action;
  final FilterOperator operator;
  final dynamic value;
  final bool isActive;
  final int priority;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggerCount;
  final Map<String, dynamic> metadata;
  final List<String> whitelistedUsers;
  final List<String> blacklistedUsers;
  final List<ContentType> applicableContentTypes;
  final ModerationSeverity severity;
  final bool autoApply;
  final String? customMessage;
  
  ModerationFilterRule({
    required this.id,
    required this.name,
    required this.description,
    required this.filterType,
    required this.action,
    required this.operator,
    required this.value,
    this.isActive = true,
    this.priority = 0,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount = 0,
    this.metadata = const {},
    this.whitelistedUsers = const [],
    this.blacklistedUsers = const [],
    this.applicableContentTypes = const [],
    this.severity = ModerationSeverity.medium,
    this.autoApply = true,
    this.customMessage,
  });
  
  factory ModerationFilterRule.fromJson(Map<String, dynamic> json) {
    final applicableContentTypes = <ContentType>[];
    if (json['applicableContentTypes'] != null) {
      final typesList = json['applicableContentTypes'] as List;
      for (final type in typesList) {
        applicableContentTypes.add(ContentTypeExtension.fromString(type));
      }
    }
    
    return ModerationFilterRule(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      filterType: ModerationFilterExtension.fromString(json['filterType']),
      action: FilterActionExtension.fromString(json['action']),
      operator: FilterOperatorExtension.fromString(json['operator']),
      value: json['value'],
      isActive: json['isActive'] ?? true,
      priority: json['priority'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null ? DateTime.parse(json['lastTriggered']) : null,
      triggerCount: json['triggerCount'] ?? 0,
      metadata: json['metadata'] ?? {},
      whitelistedUsers: List<String>.from(json['whitelistedUsers'] ?? []),
      blacklistedUsers: List<String>.from(json['blacklistedUsers'] ?? []),
      applicableContentTypes: applicableContentTypes,
      severity: ModerationSeverityExtension.fromString(json['severity']),
      autoApply: json['autoApply'] ?? true,
      customMessage: json['customMessage'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filterType': filterType.name,
      'action': action.name,
      'operator': operator.name,
      'value': value,
      'isActive': isActive,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'triggerCount': triggerCount,
      'metadata': metadata,
      'whitelistedUsers': whitelistedUsers,
      'blacklistedUsers': blacklistedUsers,
      'applicableContentTypes': applicableContentTypes.map((t) => t.name).toList(),
      'severity': severity.name,
      'autoApply': autoApply,
      'customMessage': customMessage,
    };
  }
  
  bool matches(String content, String? userId, ContentType contentType) {
    if (!isActive) return false;
    
    // Check if user is whitelisted
    if (userId != null && whitelistedUsers.contains(userId)) {
      return false;
    }
    
    // Check if user is blacklisted
    if (userId != null && blacklistedUsers.contains(userId)) {
      return true;
    }
    
    // Check if content type is applicable
    if (applicableContentTypes.isNotEmpty && !applicableContentTypes.contains(contentType)) {
      return false;
    }
    
    return _evaluateCondition(content.toLowerCase());
  }
  
  bool _evaluateCondition(String content) {
    switch (operator) {
      case FilterOperator.contains:
        return content.contains(value.toString().toLowerCase());
      case FilterOperator.equals:
        return content == value.toString().toLowerCase();
      case FilterOperator.startsWith:
        return content.startsWith(value.toString().toLowerCase());
      case FilterOperator.endsWith:
        return content.endsWith(value.toString().toLowerCase());
      case FilterOperator.regex:
        try {
          final pattern = RegExp(value.toString(), caseSensitive: false);
          return pattern.hasMatch(content);
        } catch (e) {
          return false;
        }
      case FilterOperator.greaterThan:
        if (value is num) {
          return content.length > value;
        }
        return false;
      case FilterOperator.lessThan:
        if (value is num) {
          return content.length < value;
        }
        return false;
      case FilterOperator.inList:
        if (value is List) {
          return value.any((item) => content.contains(item.toString().toLowerCase()));
        }
        return false;
      case FilterOperator.notInList:
        if (value is List) {
          return !value.any((item) => content.contains(item.toString().toLowerCase()));
        }
        return false;
    }
  }
  
  void recordTrigger() {
    lastTriggered = DateTime.now();
    triggerCount++;
  }
  
  ModerationFilterRule copyWith({
    String? id,
    String? name,
    String? description,
    ModerationFilter? filterType,
    FilterAction? action,
    FilterOperator? operator,
    dynamic value,
    bool? isActive,
    int? priority,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? triggerCount,
    Map<String, dynamic>? metadata,
    List<String>? whitelistedUsers,
    List<String>? blacklistedUsers,
    List<ContentType>? applicableContentTypes,
    ModerationSeverity? severity,
    bool? autoApply,
    String? customMessage,
  }) {
    return ModerationFilterRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      filterType: filterType ?? this.filterType,
      action: action ?? this.action,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggerCount: triggerCount ?? this.triggerCount,
      metadata: metadata ?? this.metadata,
      whitelistedUsers: whitelistedUsers ?? this.whitelistedUsers,
      blacklistedUsers: blacklistedUsers ?? this.blacklistedUsers,
      applicableContentTypes: applicableContentTypes ?? this.applicableContentTypes,
      severity: severity ?? this.severity,
      autoApply: autoApply ?? this.autoApply,
      customMessage: customMessage ?? this.customMessage,
    );
  }
}

class FilterResult {
  final String ruleId;
  final String ruleName;
  final FilterAction action;
  final ModerationSeverity severity;
  final String? customMessage;
  final bool triggered;
  final DateTime timestamp;
  final Map<String, dynamic> context;
  
  FilterResult({
    required this.ruleId,
    required this.ruleName,
    required this.action,
    required this.severity,
    this.customMessage,
    required this.triggered,
    required this.timestamp,
    this.context = const {},
  });
  
  factory FilterResult.fromJson(Map<String, dynamic> json) {
    return FilterResult(
      ruleId: json['ruleId'],
      ruleName: json['ruleName'],
      action: FilterActionExtension.fromString(json['action']),
      severity: ModerationSeverityExtension.fromString(json['severity']),
      customMessage: json['customMessage'],
      triggered: json['triggered'],
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'ruleName': ruleName,
      'action': action.name,
      'severity': severity.name,
      'customMessage': customMessage,
      'triggered': triggered,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

extension FilterActionExtension on FilterAction {
  String get displayName {
    switch (this) {
      case FilterAction.block:
        return 'Block';
      case FilterAction.flag:
        return 'Flag';
      case FilterAction.warn:
        return 'Warn';
      case FilterAction.quarantine:
        return 'Quarantine';
      case FilterAction.escalate:
        return 'Escalate';
      case FilterAction.log:
        return 'Log';
    }
  }
  
  static FilterAction fromString(String action) {
    switch (action.toLowerCase()) {
      case 'block':
        return FilterAction.block;
      case 'flag':
        return FilterAction.flag;
      case 'warn':
        return FilterAction.warn;
      case 'quarantine':
        return FilterAction.quarantine;
      case 'escalate':
        return FilterAction.escalate;
      case 'log':
        return FilterAction.log;
      default:
        return FilterAction.flag;
    }
  }
}

extension FilterOperatorExtension on FilterOperator {
  String get displayName {
    switch (this) {
      case FilterOperator.contains:
        return 'Contains';
      case FilterOperator.equals:
        return 'Equals';
      case FilterOperator.startsWith:
        return 'Starts With';
      case FilterOperator.endsWith:
        return 'Ends With';
      case FilterOperator.regex:
        return 'Regex';
      case FilterOperator.greaterThan:
        return 'Greater Than';
      case FilterOperator.lessThan:
        return 'Less Than';
      case FilterOperator.inList:
        return 'In List';
      case FilterOperator.notInList:
        return 'Not In List';
    }
  }
  
  static FilterOperator fromString(String operator) {
    switch (operator.toLowerCase()) {
      case 'contains':
        return FilterOperator.contains;
      case 'equals':
        return FilterOperator.equals;
      case 'startswith':
        return FilterOperator.startsWith;
      case 'endswith':
        return FilterOperator.endsWith;
      case 'regex':
        return FilterOperator.regex;
      case 'greaterthan':
        return FilterOperator.greaterThan;
      case 'lessthan':
        return FilterOperator.lessThan;
      case 'inlist':
        return FilterOperator.inList;
      case 'notinlist':
        return FilterOperator.notInList;
      default:
        return FilterOperator.contains;
    }
  }
}
