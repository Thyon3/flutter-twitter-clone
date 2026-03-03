import 'package:twitterclone/model/analyticsModel.dart';

enum ChartAnimationType {
  none,
  slide,
  fade,
  scale,
  bounce,
}

enum ChartInteractionType {
  none,
  tooltip,
  highlight,
  zoom,
  pan,
}

class ChartConfiguration {
  final AnalyticsChartType chartType;
  final List<AnalyticsMetric> metrics;
  final AnalyticsPeriod period;
  final AnalyticsTimeUnit timeUnit;
  final String title;
  final String? subtitle;
  final ChartAnimationType animationType;
  final ChartInteractionType interactionType;
  final bool showLegend;
  final bool showGrid;
  final bool showDataLabels;
  final bool showTrendLines;
  final bool showAverageLine;
  final bool showPeakMarkers;
  final bool showAnnotations;
  final int maxDataPoints;
  final Duration animationDuration;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color gridColor;
  final Color textColor;
  final double strokeWidth;
  final double pointSize;
  final double fontSize;
  final String? fontFamily;
  final Map<AnalyticsMetric, Color> metricColors;
  final List<ChartAnnotation> annotations;
  
  ChartConfiguration({
    required this.chartType,
    required this.metrics,
    required this.period,
    required this.timeUnit,
    required this.title,
    this.subtitle,
    this.animationType = ChartAnimationType.slide,
    this.interactionType = ChartInteractionType.tooltip,
    this.showLegend = true,
    this.showGrid = true,
    this.showDataLabels = false,
    this.showTrendLines = false,
    this.showAverageLine = false,
    this.showPeakMarkers = false,
    this.showAnnotations = false,
    this.maxDataPoints = 100,
    this.animationDuration = const Duration(milliseconds: 800),
    this.primaryColor = const Color(0xFF1DA1F2),
    this.secondaryColor = const Color(0xFF14171A),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.gridColor = const Color(0xFFE1E8ED),
    this.textColor = const Color(0xFF14171A),
    this.strokeWidth = 2.0,
    this.pointSize = 4.0,
    this.fontSize = 12.0,
    this.fontFamily,
    this.metricColors = const {},
    this.annotations = const [],
  });
  
  factory ChartConfiguration.fromJson(Map<String, dynamic> json) {
    final chartType = AnalyticsChartTypeExtension.fromString(json['chartType']);
    final metrics = <AnalyticsMetric>[];
    final metricColors = <AnalyticsMetric, Color>{};
    
    if (json['metrics'] != null) {
      final metricsList = json['metrics'] as List;
      for (final metric in metricsList) {
        metrics.add(AnalyticsMetricExtension.fromString(metric));
      }
    }
    
    if (json['metricColors'] != null) {
      final colorsMap = json['metricColors'] as Map<String, dynamic>;
      for (final entry in colorsMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        metricColors[metric] = Color(entry.value as int);
      }
    }
    
    final annotations = <ChartAnnotation>[];
    if (json['annotations'] != null) {
      final annotationsList = json['annotations'] as List;
      for (final annotation in annotationsList) {
        annotations.add(ChartAnnotation.fromJson(annotation));
      }
    }
    
    return ChartConfiguration(
      chartType: chartType,
      metrics: metrics,
      period: AnalyticsPeriodExtension.fromString(json['period']),
      timeUnit: AnalyticsTimeUnitExtension.fromString(json['timeUnit']),
      title: json['title'],
      subtitle: json['subtitle'],
      animationType: ChartAnimationTypeExtension.fromString(json['animationType']),
      interactionType: ChartInteractionTypeExtension.fromString(json['interactionType']),
      showLegend: json['showLegend'] ?? true,
      showGrid: json['showGrid'] ?? true,
      showDataLabels: json['showDataLabels'] ?? false,
      showTrendLines: json['showTrendLines'] ?? false,
      showAverageLine: json['showAverageLine'] ?? false,
      showPeakMarkers: json['showPeakMarkers'] ?? false,
      showAnnotations: json['showAnnotations'] ?? false,
      maxDataPoints: json['maxDataPoints'] ?? 100,
      animationDuration: Duration(milliseconds: json['animationDuration'] ?? 800),
      primaryColor: Color(json['primaryColor'] ?? 0xFF1DA1F2),
      secondaryColor: Color(json['secondaryColor'] ?? 0xFF14171A),
      backgroundColor: Color(json['backgroundColor'] ?? 0xFFFFFFFF),
      gridColor: Color(json['gridColor'] ?? 0xFFE1E8ED),
      textColor: Color(json['textColor'] ?? 0xFF14171A),
      strokeWidth: (json['strokeWidth'] ?? 2.0).toDouble(),
      pointSize: (json['pointSize'] ?? 4.0).toDouble(),
      fontSize: (json['fontSize'] ?? 12.0).toDouble(),
      fontFamily: json['fontFamily'],
      metricColors: metricColors,
      annotations: annotations,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'chartType': chartType.name,
      'metrics': metrics.map((m) => m.name).toList(),
      'period': period.name,
      'timeUnit': timeUnit.name,
      'title': title,
      'subtitle': subtitle,
      'animationType': animationType.name,
      'interactionType': interactionType.name,
      'showLegend': showLegend,
      'showGrid': showGrid,
      'showDataLabels': showDataLabels,
      'showTrendLines': showTrendLines,
      'showAverageLine': showAverageLine,
      'showPeakMarkers': showPeakMarkers,
      'showAnnotations': showAnnotations,
      'maxDataPoints': maxDataPoints,
      'animationDuration': animationDuration.inMilliseconds,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'gridColor': gridColor.value,
      'textColor': textColor.value,
      'strokeWidth': strokeWidth,
      'pointSize': pointSize,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'metricColors': metricColors.map((key, value) => MapEntry(key.name, value.value)),
      'annotations': annotations.map((a) => a.toJson()).toList(),
    };
  }
  
  ChartConfiguration copyWith({
    AnalyticsChartType? chartType,
    List<AnalyticsMetric>? metrics,
    AnalyticsPeriod? period,
    AnalyticsTimeUnit? timeUnit,
    String? title,
    String? subtitle,
    ChartAnimationType? animationType,
    ChartInteractionType? interactionType,
    bool? showLegend,
    bool? showGrid,
    bool? showDataLabels,
    bool? showTrendLines,
    bool? showAverageLine,
    bool? showPeakMarkers,
    bool? showAnnotations,
    int? maxDataPoints,
    Duration? animationDuration,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? gridColor,
    Color? textColor,
    double? strokeWidth,
    double? pointSize,
    double? fontSize,
    String? fontFamily,
    Map<AnalyticsMetric, Color>? metricColors,
    List<ChartAnnotation>? annotations,
  }) {
    return ChartConfiguration(
      chartType: chartType ?? this.chartType,
      metrics: metrics ?? this.metrics,
      period: period ?? this.period,
      timeUnit: timeUnit ?? this.timeUnit,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      animationType: animationType ?? this.animationType,
      interactionType: interactionType ?? this.interactionType,
      showLegend: showLegend ?? this.showLegend,
      showGrid: showGrid ?? this.showGrid,
      showDataLabels: showDataLabels ?? this.showDataLabels,
      showTrendLines: showTrendLines ?? this.showTrendLines,
      showAverageLine: showAverageLine ?? this.showAverageLine,
      showPeakMarkers: showPeakMarkers ?? this.showPeakMarkers,
      showAnnotations: showAnnotations ?? this.showAnnotations,
      maxDataPoints: maxDataPoints ?? this.maxDataPoints,
      animationDuration: animationDuration ?? this.animationDuration,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      textColor: textColor ?? this.textColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      pointSize: pointSize ?? this.pointSize,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      metricColors: metricColors ?? this.metricColors,
      annotations: annotations ?? this.annotations,
    );
  }
}

class ChartAnnotation {
  final DateTime timestamp;
  final String text;
  final Color color;
  final ChartAnnotationType type;
  final Map<String, dynamic> metadata;
  
  ChartAnnotation({
    required this.timestamp,
    required this.text,
    this.color = const Color(0xFFE0245E),
    this.type = ChartAnnotationType.event,
    this.metadata = const {},
  });
  
  factory ChartAnnotation.fromJson(Map<String, dynamic> json) {
    return ChartAnnotation(
      timestamp: DateTime.parse(json['timestamp']),
      text: json['text'],
      color: Color(json['color'] ?? 0xFFE0245E),
      type: ChartAnnotationTypeExtension.fromString(json['type']),
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'text': text,
      'color': color.value,
      'type': type.name,
      'metadata': metadata,
    };
  }
}

enum ChartAnnotationType {
  event,
  milestone,
  peak,
  drop,
  note,
}

extension ChartAnimationTypeExtension on ChartAnimationType {
  String get displayName {
    switch (this) {
      case ChartAnimationType.none:
        return 'None';
      case ChartAnimationType.slide:
        return 'Slide';
      case ChartAnimationType.fade:
        return 'Fade';
      case ChartAnimationType.scale:
        return 'Scale';
      case ChartAnimationType.bounce:
        return 'Bounce';
    }
  }
  
  static ChartAnimationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'none':
        return ChartAnimationType.none;
      case 'slide':
        return ChartAnimationType.slide;
      case 'fade':
        return ChartAnimationType.fade;
      case 'scale':
        return ChartAnimationType.scale;
      case 'bounce':
        return ChartAnimationType.bounce;
      default:
        return ChartAnimationType.slide;
    }
  }
}

extension ChartInteractionTypeExtension on ChartInteractionType {
  String get displayName {
    switch (this) {
      case ChartInteractionType.none:
        return 'None';
      case ChartInteractionType.tooltip:
        return 'Tooltip';
      case ChartInteractionType.highlight:
        return 'Highlight';
      case ChartInteractionType.zoom:
        return 'Zoom';
      case ChartInteractionType.pan:
        return 'Pan';
    }
  }
  
  static ChartInteractionType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'none':
        return ChartInteractionType.none;
      case 'tooltip':
        return ChartInteractionType.tooltip;
      case 'highlight':
        return ChartInteractionType.highlight;
      case 'zoom':
        return ChartInteractionType.zoom;
      case 'pan':
        return ChartInteractionType.pan;
      default:
        return ChartInteractionType.tooltip;
    }
  }
}

extension ChartAnnotationTypeExtension on ChartAnnotationType {
  String get displayName {
    switch (this) {
      case ChartAnnotationType.event:
        return 'Event';
      case ChartAnnotationType.milestone:
        return 'Milestone';
      case ChartAnnotationType.peak:
        return 'Peak';
      case ChartAnnotationType.drop:
        return 'Drop';
      case ChartAnnotationType.note:
        return 'Note';
    }
  }
  
  static ChartAnnotationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'event':
        return ChartAnnotationType.event;
      case 'milestone':
        return ChartAnnotationType.milestone;
      case 'peak':
        return ChartAnnotationType.peak;
      case 'drop':
        return ChartAnnotationType.drop;
      case 'note':
        return ChartAnnotationType.note;
      default:
        return ChartAnnotationType.event;
    }
  }
}

import 'package:flutter/material.dart';
