import 'package:twitterclone/model/moderationModel.dart';

enum ModerationMetric {
  totalReports,
  pendingReports,
  resolvedReports,
  averageResolutionTime,
  reportsByReason,
  reportsByContentType,
  reportsBySeverity,
  reportsByAction,
  moderatorPerformance,
  autoModerationAccuracy,
  falsePositiveRate,
  falseNegativeRate,
  escalationRate,
  queueEfficiency,
  moderatorWorkload,
  responseTime,
}

enum TimePeriod {
  hourly,
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

class ModerationAnalytics {
  final String id;
  final TimePeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final Map<ModerationMetric, dynamic> metrics;
  final Map<String, int> reportsByReason;
  final Map<String, int> reportsByContentType;
  final Map<String, int> reportsBySeverity;
  final Map<String, int> reportsByAction;
  final Map<String, dynamic> moderatorPerformance;
  final List<ModerationTrend> trends;
  final DateTime generatedAt;
  
  ModerationAnalytics({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.metrics,
    required this.reportsByReason,
    required this.reportsByContentType,
    required this.reportsBySeverity,
    required this.reportsByAction,
    required this.moderatorPerformance,
    required this.trends,
    required this.generatedAt,
  });
  
  factory ModerationAnalytics.fromJson(Map<String, dynamic> json) {
    final metrics = <ModerationMetric, dynamic>{};
    if (json['metrics'] != null) {
      final metricsMap = json['metrics'] as Map<String, dynamic>;
      for (final entry in metricsMap.entries) {
        final metric = ModerationMetricExtension.fromString(entry.key);
        metrics[metric] = entry.value;
      }
    }
    
    final trends = <ModerationTrend>[];
    if (json['trends'] != null) {
      final trendsList = json['trends'] as List;
      for (final trend in trendsList) {
        trends.add(ModerationTrend.fromJson(trend));
      }
    }
    
    return ModerationAnalytics(
      id: json['id'],
      period: TimePeriodExtension.fromString(json['period']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      metrics: metrics,
      reportsByReason: Map<String, int>.from(json['reportsByReason'] ?? {}),
      reportsByContentType: Map<String, int>.from(json['reportsByContentType'] ?? {}),
      reportsBySeverity: Map<String, int>.from(json['reportsBySeverity'] ?? {}),
      reportsByAction: Map<String, int>.from(json['reportsByAction'] ?? {}),
      moderatorPerformance: Map<String, dynamic>.from(json['moderatorPerformance'] ?? {}),
      trends: trends,
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'metrics': metrics.map((key, value) => MapEntry(key.name, value)),
      'reportsByReason': reportsByReason,
      'reportsByContentType': reportsByContentType,
      'reportsBySeverity': reportsBySeverity,
      'reportsByAction': reportsByAction,
      'moderatorPerformance': moderatorPerformance,
      'trends': trends.map((t) => t.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
  
  T? getMetric<T>(ModerationMetric metric) {
    return metrics[metric] as T?;
  }
  
  double getResolutionRate {
    final total = getMetric<int>(ModerationMetric.totalReports) ?? 0;
    final resolved = getMetric<int>(ModerationMetric.resolvedReports) ?? 0;
    return total > 0 ? (resolved / total) * 100 : 0.0;
  }
  
  double getEscalationRate {
    final total = getMetric<int>(ModerationMetric.totalReports) ?? 0;
    final escalated = getMetric<int>(ModerationMetric.escalationRate) ?? 0;
    return total > 0 ? (escalated / total) * 100 : 0.0;
  }
  
  Duration getAverageResolutionTime {
    final minutes = getMetric<int>(ModerationMetric.averageResolutionTime) ?? 0;
    return Duration(minutes: minutes);
  }
}

class ModerationTrend {
  final DateTime timestamp;
  final Map<ModerationMetric, dynamic> values;
  final String? label;
  final Map<String, dynamic> metadata;
  
  ModerationTrend({
    required this.timestamp,
    required this.values,
    this.label,
    this.metadata = const {},
  });
  
  factory ModerationTrend.fromJson(Map<String, dynamic> json) {
    final values = <ModerationMetric, dynamic>{};
    if (json['values'] != null) {
      final valuesMap = json['values'] as Map<String, dynamic>;
      for (final entry in valuesMap.entries) {
        final metric = ModerationMetricExtension.fromString(entry.key);
        values[metric] = entry.value;
      }
    }
    
    return ModerationTrend(
      timestamp: DateTime.parse(json['timestamp']),
      values: values,
      label: json['label'],
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'values': values.map((key, value) => MapEntry(key.name, value)),
      'label': label,
      'metadata': metadata,
    };
  }
  
  T? getValue<T>(ModerationMetric metric) {
    return values[metric] as T?;
  }
}

class ModeratorPerformance {
  final String moderatorId;
  final String moderatorName;
  final int reportsHandled;
  final int reportsResolved;
  final double resolutionRate;
  final Duration averageResolutionTime;
  final int escalations;
  final int appeals;
  final double accuracy;
  final DateTime lastActive;
  final List<String> specializations;
  final Map<String, int> actionsByType;
  final double workloadScore;
  final double efficiencyScore;
  
  ModeratorPerformance({
    required this.moderatorId,
    required this.moderatorName,
    required this.reportsHandled,
    required this.reportsResolved,
    required this.resolutionRate,
    required this.averageResolutionTime,
    required this.escalations,
    required this.appeals,
    required this.accuracy,
    required this.lastActive,
    required this.specializations,
    required this.actionsByType,
    required this.workloadScore,
    required this.efficiencyScore,
  });
  
  factory ModeratorPerformance.fromJson(Map<String, dynamic> json) {
    return ModeratorPerformance(
      moderatorId: json['moderatorId'],
      moderatorName: json['moderatorName'],
      reportsHandled: json['reportsHandled'],
      reportsResolved: json['reportsResolved'],
      resolutionRate: (json['resolutionRate'] as num).toDouble(),
      averageResolutionTime: Duration(minutes: json['averageResolutionTime'] ?? 0),
      escalations: json['escalations'],
      appeals: json['appeals'],
      accuracy: (json['accuracy'] as num).toDouble(),
      lastActive: DateTime.parse(json['lastActive']),
      specializations: List<String>.from(json['specializations'] ?? []),
      actionsByType: Map<String, int>.from(json['actionsByType'] ?? {}),
      workloadScore: (json['workloadScore'] as num).toDouble(),
      efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'moderatorId': moderatorId,
      'moderatorName': moderatorName,
      'reportsHandled': reportsHandled,
      'reportsResolved': reportsResolved,
      'resolutionRate': resolutionRate,
      'averageResolutionTime': averageResolutionTime.inMinutes,
      'escalations': escalations,
      'appeals': appeals,
      'accuracy': accuracy,
      'lastActive': lastActive.toIso8601String(),
      'specializations': specializations,
      'actionsByType': actionsByType,
      'workloadScore': workloadScore,
      'efficiencyScore': efficiencyScore,
    };
  }
  
  String get performanceGrade {
    if (accuracy >= 0.95 && efficiencyScore >= 0.9) return 'A+';
    if (accuracy >= 0.90 && efficiencyScore >= 0.8) return 'A';
    if (accuracy >= 0.85 && efficiencyScore >= 0.7) return 'B';
    if (accuracy >= 0.80 && efficiencyScore >= 0.6) return 'C';
    if (accuracy >= 0.75 && efficiencyScore >= 0.5) return 'D';
    return 'F';
  }
  
  bool get isTopPerformer => performanceGrade.startsWith('A');
  
  bool get needsImprovement => performanceGrade == 'F';
}

class ModerationReport {
  final String id;
  final String title;
  final String description;
  final TimePeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final List<String> chartUrls;
  final List<ModerationInsight> insights;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String generatedBy;
  final bool isPublic;
  final List<String> sharedWith;
  
  ModerationReport({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.chartUrls,
    required this.insights,
    required this.recommendations,
    required this.generatedAt,
    required this.generatedBy,
    this.isPublic = false,
    this.sharedWith = const [],
  });
  
  factory ModerationReport.fromJson(Map<String, dynamic> json) {
    final insights = <ModerationInsight>[];
    if (json['insights'] != null) {
      final insightsList = json['insights'] as List;
      for (final insight in insightsList) {
        insights.add(ModerationInsight.fromJson(insight));
      }
    }
    
    return ModerationReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      period: TimePeriodExtension.fromString(json['period']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      data: json['data'] ?? {},
      chartUrls: List<String>.from(json['chartUrls'] ?? []),
      insights: insights,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
      generatedBy: json['generatedBy'],
      isPublic: json['isPublic'] ?? false,
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'data': data,
      'chartUrls': chartUrls,
      'insights': insights.map((i) => i.toJson()).toList(),
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
      'generatedBy': generatedBy,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
    };
  }
}

class ModerationInsight {
  final String title;
  final String description;
  final String type;
  final double impact;
  final Map<String, dynamic> data;
  final List<String> actionItems;
  
  ModerationInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.data,
    required this.actionItems,
  });
  
  factory ModerationInsight.fromJson(Map<String, dynamic> json) {
    return ModerationInsight(
      title: json['title'],
      description: json['description'],
      type: json['type'],
      impact: (json['impact'] as num).toDouble(),
      data: json['data'] ?? {},
      actionItems: List<String>.from(json['actionItems'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'impact': impact,
      'data': data,
      'actionItems': actionItems,
    };
  }
  
  String get severity {
    if (impact >= 0.8) return 'Critical';
    if (impact >= 0.6) return 'High';
    if (impact >= 0.4) return 'Medium';
    return 'Low';
  }
}

extension ModerationMetricExtension on ModerationMetric {
  String get displayName {
    switch (this) {
      case ModerationMetric.totalReports:
        return 'Total Reports';
      case ModerationMetric.pendingReports:
        return 'Pending Reports';
      case ModerationMetric.resolvedReports:
        return 'Resolved Reports';
      case ModerationMetric.averageResolutionTime:
        return 'Average Resolution Time';
      case ModerationMetric.reportsByReason:
        return 'Reports by Reason';
      case ModerationMetric.reportsByContentType:
        return 'Reports by Content Type';
      case ModerationMetric.reportsBySeverity:
        return 'Reports by Severity';
      case ModerationMetric.reportsByAction:
        return 'Reports by Action';
      case ModerationMetric.moderatorPerformance:
        return 'Moderator Performance';
      case ModerationMetric.autoModerationAccuracy:
        return 'Auto Moderation Accuracy';
      case ModerationMetric.falsePositiveRate:
        return 'False Positive Rate';
      case ModerationMetric.falseNegativeRate:
        return 'False Negative Rate';
      case ModerationMetric.escalationRate:
        return 'Escalation Rate';
      case ModerationMetric.queueEfficiency:
        return 'Queue Efficiency';
      case ModerationMetric.moderatorWorkload:
        return 'Moderator Workload';
      case ModerationMetric.responseTime:
        return 'Response Time';
    }
  }
  
  static ModerationMetric fromString(String metric) {
    switch (metric.toLowerCase()) {
      case 'totalreports':
        return ModerationMetric.totalReports;
      case 'pendingreports':
        return ModerationMetric.pendingReports;
      case 'resolvedreports':
        return ModerationMetric.resolvedReports;
      case 'averageresolutiontime':
        return ModerationMetric.averageResolutionTime;
      case 'reportsbyreason':
        return ModerationMetric.reportsByReason;
      case 'reportsbycontenttype':
        return ModerationMetric.reportsByContentType;
      case 'reportsbyseverity':
        return ModerationMetric.reportsBySeverity;
      case 'reportsbyaction':
        return ModerationMetric.reportsByAction;
      case 'moderatorperformance':
        return ModerationMetric.moderatorPerformance;
      case 'automoderationaccuracy':
        return ModerationMetric.autoModerationAccuracy;
      case 'falsepositiverate':
        return ModerationMetric.falsePositiveRate;
      case 'falsenegativerate':
        return ModerationMetric.falseNegativeRate;
      case 'escalationrate':
        return ModerationMetric.escalationRate;
      case 'queueefficiency':
        return ModerationMetric.queueEfficiency;
      case 'moderatorworkload':
        return ModerationMetric.moderatorWorkload;
      case 'responsetime':
        return ModerationMetric.responseTime;
      default:
        return ModerationMetric.totalReports;
    }
  }
}

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.hourly:
        return 'Hourly';
      case TimePeriod.daily:
        return 'Daily';
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
      case TimePeriod.quarterly:
        return 'Quarterly';
      case TimePeriod.yearly:
        return 'Yearly';
    }
  }
  
  static TimePeriod fromString(String period) {
    switch (period.toLowerCase()) {
      case 'hourly':
        return TimePeriod.hourly;
      case 'daily':
        return TimePeriod.daily;
      case 'weekly':
        return TimePeriod.weekly;
      case 'monthly':
        return TimePeriod.monthly;
      case 'quarterly':
        return TimePeriod.quarterly;
      case 'yearly':
        return TimePeriod.yearly;
      default:
        return TimePeriod.daily;
    }
  }
}
