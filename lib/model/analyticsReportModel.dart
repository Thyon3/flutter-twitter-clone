import 'package:twitterclone/model/analyticsModel.dart';

enum ReportFormat {
  pdf,
  csv,
  excel,
  json,
  png,
  svg,
}

enum ReportType {
  summary,
  detailed,
  comparison,
  trend,
  performance,
  engagement,
  growth,
  demographic,
}

enum ReportSchedule {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom,
}

class AnalyticsReport {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final ReportFormat format;
  final AnalyticsPeriod period;
  final List<AnalyticsMetric> metrics;
  final Map<String, dynamic> data;
  final List<String> chartUrls;
  final DateTime generatedAt;
  final DateTime? validUntil;
  final String? filePath;
  final int fileSize;
  final bool isPublic;
  final List<String> sharedWith;
  final Map<String, dynamic> metadata;
  
  AnalyticsReport({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.format,
    required this.period,
    required this.metrics,
    required this.data,
    required this.chartUrls,
    required this.generatedAt,
    this.validUntil,
    this.filePath,
    required this.fileSize,
    this.isPublic = false,
    this.sharedWith = const [],
    this.metadata = const {},
  });
  
  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    final type = ReportTypeExtension.fromString(json['type']);
    final format = ReportFormatExtension.fromString(json['format']);
    final period = AnalyticsPeriodExtension.fromString(json['period']);
    final metrics = <AnalyticsMetric>[];
    
    if (json['metrics'] != null) {
      final metricsList = json['metrics'] as List;
      for (final metric in metricsList) {
        metrics.add(AnalyticsMetricExtension.fromString(metric));
      }
    }
    
    return AnalyticsReport(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: type,
      format: format,
      period: period,
      metrics: metrics,
      data: json['data'] ?? {},
      chartUrls: List<String>.from(json['chartUrls'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt']),
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
      filePath: json['filePath'],
      fileSize: json['fileSize'] ?? 0,
      isPublic: json['isPublic'] ?? false,
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'format': format.name,
      'period': period.name,
      'metrics': metrics.map((m) => m.name).toList(),
      'data': data,
      'chartUrls': chartUrls,
      'generatedAt': generatedAt.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'filePath': filePath,
      'fileSize': fileSize,
      'isPublic': isPublic,
      'sharedWith': sharedWith,
      'metadata': metadata,
    };
  }
  
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }
  
  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final List<AnalyticsMetric> defaultMetrics;
  final List<AnalyticsPeriod> supportedPeriods;
  final List<ReportFormat> supportedFormats;
  final Map<String, dynamic> defaultSettings;
  final bool isDefault;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.defaultMetrics,
    required this.supportedPeriods,
    required this.supportedFormats,
    required this.defaultSettings,
    this.isDefault = false,
    this.isPremium = false,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    final type = ReportTypeExtension.fromString(json['type']);
    final defaultMetrics = <AnalyticsMetric>[];
    final supportedPeriods = <AnalyticsPeriod>[];
    final supportedFormats = <ReportFormat>[];
    
    if (json['defaultMetrics'] != null) {
      final metricsList = json['defaultMetrics'] as List;
      for (final metric in metricsList) {
        defaultMetrics.add(AnalyticsMetricExtension.fromString(metric));
      }
    }
    
    if (json['supportedPeriods'] != null) {
      final periodsList = json['supportedPeriods'] as List;
      for (final period in periodsList) {
        supportedPeriods.add(AnalyticsPeriodExtension.fromString(period));
      }
    }
    
    if (json['supportedFormats'] != null) {
      final formatsList = json['supportedFormats'] as List;
      for (final format in formatsList) {
        supportedFormats.add(ReportFormatExtension.fromString(format));
      }
    }
    
    return ReportTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: type,
      defaultMetrics: defaultMetrics,
      supportedPeriods: supportedPeriods,
      supportedFormats: supportedFormats,
      defaultSettings: json['defaultSettings'] ?? {},
      isDefault: json['isDefault'] ?? false,
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'defaultMetrics': defaultMetrics.map((m) => m.name).toList(),
      'supportedPeriods': supportedPeriods.map((p) => p.name).toList(),
      'supportedFormats': supportedFormats.map((f) => f.name).toList(),
      'defaultSettings': defaultSettings,
      'isDefault': isDefault,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ScheduledReport {
  final String id;
  final String name;
  final ReportTemplate template;
  final ReportSchedule schedule;
  final AnalyticsPeriod period;
  final List<AnalyticsMetric> metrics;
  final ReportFormat format;
  final List<String> recipients;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastRun;
  final DateTime? nextRun;
  final int runCount;
  final Map<String, dynamic> settings;
  
  ScheduledReport({
    required this.id,
    required this.name,
    required this.template,
    required this.schedule,
    required this.period,
    required this.metrics,
    required this.format,
    required this.recipients,
    this.isActive = true,
    required this.createdAt,
    this.lastRun,
    this.nextRun,
    this.runCount = 0,
    this.settings = const {},
  });
  
  factory ScheduledReport.fromJson(Map<String, dynamic> json) {
    final template = ReportTemplate.fromJson(json['template']);
    final schedule = ReportScheduleExtension.fromString(json['schedule']);
    final period = AnalyticsPeriodExtension.fromString(json['period']);
    final format = ReportFormatExtension.fromString(json['format']);
    final metrics = <AnalyticsMetric>[];
    
    if (json['metrics'] != null) {
      final metricsList = json['metrics'] as List;
      for (final metric in metricsList) {
        metrics.add(AnalyticsMetricExtension.fromString(metric));
      }
    }
    
    return ScheduledReport(
      id: json['id'],
      name: json['name'],
      template: template,
      schedule: schedule,
      period: period,
      metrics: metrics,
      format: format,
      recipients: List<String>.from(json['recipients'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastRun: json['lastRun'] != null ? DateTime.parse(json['lastRun']) : null,
      nextRun: json['nextRun'] != null ? DateTime.parse(json['nextRun']) : null,
      runCount: json['runCount'] ?? 0,
      settings: json['settings'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'template': template.toJson(),
      'schedule': schedule.name,
      'period': period.name,
      'metrics': metrics.map((m) => m.name).toList(),
      'format': format.name,
      'recipients': recipients,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastRun': lastRun?.toIso8601String(),
      'nextRun': nextRun?.toIso8601String(),
      'runCount': runCount,
      'settings': settings,
    };
  }
  
  DateTime calculateNextRun() {
    final now = DateTime.now();
    
    switch (schedule) {
      case ReportSchedule.daily:
        return DateTime(now.year, now.month, now.day + 1);
      case ReportSchedule.weekly:
        final nextWeek = now.add(Duration(days: 7 - now.weekday));
        return DateTime(nextWeek.year, nextWeek.month, nextWeek.day);
      case ReportSchedule.monthly:
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return nextMonth;
      case ReportSchedule.quarterly:
        final currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final nextQuarter = currentQuarter == 4 ? 1 : currentQuarter + 1;
        final year = currentQuarter == 4 ? now.year + 1 : now.year;
        return DateTime(year, (nextQuarter - 1) * 3 + 1, 1);
      case ReportSchedule.yearly:
        return DateTime(now.year + 1, 1, 1);
      case ReportSchedule.custom:
        // Custom schedule would be stored in settings
        return now.add(Duration(days: 7)); // Default to weekly
    }
  }
}

extension ReportFormatExtension on ReportFormat {
  String get displayName {
    switch (this) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.csv:
        return 'CSV';
      case ReportFormat.excel:
        return 'Excel';
      case ReportFormat.json:
        return 'JSON';
      case ReportFormat.png:
        return 'PNG';
      case ReportFormat.svg:
        return 'SVG';
    }
  }
  
  String get mimeType {
    switch (this) {
      case ReportFormat.pdf:
        return 'application/pdf';
      case ReportFormat.csv:
        return 'text/csv';
      case ReportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ReportFormat.json:
        return 'application/json';
      case ReportFormat.png:
        return 'image/png';
      case ReportFormat.svg:
        return 'image/svg+xml';
    }
  }
  
  String get fileExtension {
    switch (this) {
      case ReportFormat.pdf:
        return '.pdf';
      case ReportFormat.csv:
        return '.csv';
      case ReportFormat.excel:
        return '.xlsx';
      case ReportFormat.json:
        return '.json';
      case ReportFormat.png:
        return '.png';
      case ReportFormat.svg:
        return '.svg';
    }
  }
  
  static ReportFormat fromString(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return ReportFormat.pdf;
      case 'csv':
        return ReportFormat.csv;
      case 'excel':
        return ReportFormat.excel;
      case 'json':
        return ReportFormat.json;
      case 'png':
        return ReportFormat.png;
      case 'svg':
        return ReportFormat.svg;
      default:
        return ReportFormat.pdf;
    }
  }
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.summary:
        return 'Summary';
      case ReportType.detailed:
        return 'Detailed';
      case ReportType.comparison:
        return 'Comparison';
      case ReportType.trend:
        return 'Trend Analysis';
      case ReportType.performance:
        return 'Performance';
      case ReportType.engagement:
        return 'Engagement';
      case ReportType.growth:
        return 'Growth';
      case ReportType.demographic:
        return 'Demographic';
    }
  }
  
  static ReportType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'summary':
        return ReportType.summary;
      case 'detailed':
        return ReportType.detailed;
      case 'comparison':
        return ReportType.comparison;
      case 'trend':
        return ReportType.trend;
      case 'performance':
        return ReportType.performance;
      case 'engagement':
        return ReportType.engagement;
      case 'growth':
        return ReportType.growth;
      case 'demographic':
        return ReportType.demographic;
      default:
        return ReportType.summary;
    }
  }
}

extension ReportScheduleExtension on ReportSchedule {
  String get displayName {
    switch (this) {
      case ReportSchedule.daily:
        return 'Daily';
      case ReportSchedule.weekly:
        return 'Weekly';
      case ReportSchedule.monthly:
        return 'Monthly';
      case ReportSchedule.quarterly:
        return 'Quarterly';
      case ReportSchedule.yearly:
        return 'Yearly';
      case ReportSchedule.custom:
        return 'Custom';
    }
  }
  
  static ReportSchedule fromString(String schedule) {
    switch (schedule.toLowerCase()) {
      case 'daily':
        return ReportSchedule.daily;
      case 'weekly':
        return ReportSchedule.weekly;
      case 'monthly':
        return ReportSchedule.monthly;
      case 'quarterly':
        return ReportSchedule.quarterly;
      case 'yearly':
        return ReportSchedule.yearly;
      case 'custom':
        return ReportSchedule.custom;
      default:
        return ReportSchedule.monthly;
    }
  }
}
