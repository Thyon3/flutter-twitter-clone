enum AnalyticsPeriod {
  today,
  week,
  month,
  quarter,
  year,
  all,
}

enum AnalyticsMetric {
  impressions,
  engagements,
  likes,
  retweets,
  replies,
  profileViews,
  linkClicks,
  mentions,
  quoteTweets,
  bookmarks,
  followers,
  following,
  tweets,
  mediaViews,
}

enum AnalyticsChartType {
  line,
  bar,
  pie,
  area,
  scatter,
}

enum AnalyticsTimeUnit {
  hour,
  day,
  week,
  month,
}

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.today:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.quarter:
        return 'This Quarter';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.all:
        return 'All Time';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case AnalyticsPeriod.week:
        return now.subtract(Duration(days: now.weekday - 1));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsPeriod.quarter:
        final quarter = ((now.month - 1) ~/ 3) + 1;
        return DateTime(now.year, (quarter - 1) * 3 + 1, 1);
      case AnalyticsPeriod.year:
        return DateTime(now.year, 1, 1);
      case AnalyticsPeriod.all:
        return DateTime(2000, 1, 1); // Far back date
    }
  }

  static AnalyticsPeriod fromString(String period) {
    switch (period.toLowerCase()) {
      case 'today':
        return AnalyticsPeriod.today;
      case 'week':
        return AnalyticsPeriod.week;
      case 'month':
        return AnalyticsPeriod.month;
      case 'quarter':
        return AnalyticsPeriod.quarter;
      case 'year':
        return AnalyticsPeriod.year;
      case 'all':
        return AnalyticsPeriod.all;
      default:
        return AnalyticsPeriod.month;
    }
  }
}

extension AnalyticsMetricExtension on AnalyticsMetric {
  String get displayName {
    switch (this) {
      case AnalyticsMetric.impressions:
        return 'Impressions';
      case AnalyticsMetric.engagements:
        return 'Engagements';
      case AnalyticsMetric.likes:
        return 'Likes';
      case AnalyticsMetric.retweets:
        return 'Retweets';
      case AnalyticsMetric.replies:
        return 'Replies';
      case AnalyticsMetric.profileViews:
        return 'Profile Views';
      case AnalyticsMetric.linkClicks:
        return 'Link Clicks';
      case AnalyticsMetric.mentions:
        return 'Mentions';
      case AnalyticsMetric.quoteTweets:
        return 'Quote Tweets';
      case AnalyticsMetric.bookmarks:
        return 'Bookmarks';
      case AnalyticsMetric.followers:
        return 'Followers';
      case AnalyticsMetric.following:
        return 'Following';
      case AnalyticsMetric.tweets:
        return 'Tweets';
      case AnalyticsMetric.mediaViews:
        return 'Media Views';
    }
  }

  String get unit {
    switch (this) {
      case AnalyticsMetric.impressions:
      case AnalyticsMetric.engagements:
      case AnalyticsMetric.likes:
      case AnalyticsMetric.retweets:
      case AnalyticsMetric.replies:
      case AnalyticsMetric.profileViews:
      case AnalyticsMetric.linkClicks:
      case AnalyticsMetric.mentions:
      case AnalyticsMetric.quoteTweets:
      case AnalyticsMetric.bookmarks:
      case AnalyticsMetric.followers:
      case AnalyticsMetric.following:
      case AnalyticsMetric.tweets:
      case AnalyticsMetric.mediaViews:
        return 'count';
    }
  }

  static AnalyticsMetric fromString(String metric) {
    switch (metric.toLowerCase()) {
      case 'impressions':
        return AnalyticsMetric.impressions;
      case 'engagements':
        return AnalyticsMetric.engagements;
      case 'likes':
        return AnalyticsMetric.likes;
      case 'retweets':
        return AnalyticsMetric.retweets;
      case 'replies':
        return AnalyticsMetric.replies;
      case 'profileviews':
        return AnalyticsMetric.profileViews;
      case 'linkclicks':
        return AnalyticsMetric.linkClicks;
      case 'mentions':
        return AnalyticsMetric.mentions;
      case 'quotetweets':
        return AnalyticsMetric.quoteTweets;
      case 'bookmarks':
        return AnalyticsMetric.bookmarks;
      case 'followers':
        return AnalyticsMetric.followers;
      case 'following':
        return AnalyticsMetric.following;
      case 'tweets':
        return AnalyticsMetric.tweets;
      case 'mediaviews':
        return AnalyticsMetric.mediaViews;
      default:
        return AnalyticsMetric.impressions;
    }
  }
}

extension AnalyticsChartTypeExtension on AnalyticsChartType {
  String get displayName {
    switch (this) {
      case AnalyticsChartType.line:
        return 'Line Chart';
      case AnalyticsChartType.bar:
        return 'Bar Chart';
      case AnalyticsChartType.pie:
        return 'Pie Chart';
      case AnalyticsChartType.area:
        return 'Area Chart';
      case AnalyticsChartType.scatter:
        return 'Scatter Plot';
    }
  }

  static AnalyticsChartType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'line':
        return AnalyticsChartType.line;
      case 'bar':
        return AnalyticsChartType.bar;
      case 'pie':
        return AnalyticsChartType.pie;
      case 'area':
        return AnalyticsChartType.area;
      case 'scatter':
        return AnalyticsChartType.scatter;
      default:
        return AnalyticsChartType.line;
    }
  }
}

extension AnalyticsTimeUnitExtension on AnalyticsTimeUnit {
  String get displayName {
    switch (this) {
      case AnalyticsTimeUnit.hour:
        return 'Hourly';
      case AnalyticsTimeUnit.day:
        return 'Daily';
      case AnalyticsTimeUnit.week:
        return 'Weekly';
      case AnalyticsTimeUnit.month:
        return 'Monthly';
    }
  }

  static AnalyticsTimeUnit fromString(String unit) {
    switch (unit.toLowerCase()) {
      case 'hour':
        return AnalyticsTimeUnit.hour;
      case 'day':
        return AnalyticsTimeUnit.day;
      case 'week':
        return AnalyticsTimeUnit.week;
      case 'month':
        return AnalyticsTimeUnit.month;
      default:
        return AnalyticsTimeUnit.day;
    }
  }
}

class AnalyticsDataPoint {
  final DateTime timestamp;
  final Map<AnalyticsMetric, int> values;
  
  AnalyticsDataPoint({
    required this.timestamp,
    required this.values,
  });
  
  factory AnalyticsDataPoint.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.parse(json['timestamp']);
    final values = <AnalyticsMetric, int>{};
    
    if (json['values'] != null) {
      final valuesMap = json['values'] as Map<String, dynamic>;
      for (final entry in valuesMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        values[metric] = entry.value as int;
      }
    }
    
    return AnalyticsDataPoint(
      timestamp: timestamp,
      values: values,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'values': values.map((key, value) => MapEntry(key.name, value)),
    };
  }
  
  int? getValue(AnalyticsMetric metric) {
    return values[metric];
  }
  
  void setValue(AnalyticsMetric metric, int value) {
    values[metric] = value;
  }
}

class AnalyticsSummary {
  final AnalyticsPeriod period;
  final Map<AnalyticsMetric, int> totals;
  final Map<AnalyticsMetric, double> averages;
  final Map<AnalyticsMetric, int> peaks;
  final Map<AnalyticsMetric, int> previousPeriod;
  final DateTime generatedAt;
  
  AnalyticsSummary({
    required this.period,
    required this.totals,
    required this.averages,
    required this.peaks,
    required this.previousPeriod,
    required this.generatedAt,
  });
  
  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    final period = AnalyticsPeriodExtension.fromString(json['period']);
    final totals = <AnalyticsMetric, int>{};
    final averages = <AnalyticsMetric, double>{};
    final peaks = <AnalyticsMetric, int>{};
    final previousPeriod = <AnalyticsMetric, int>{};
    
    if (json['totals'] != null) {
      final totalsMap = json['totals'] as Map<String, dynamic>;
      for (final entry in totalsMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        totals[metric] = entry.value as int;
      }
    }
    
    if (json['averages'] != null) {
      final averagesMap = json['averages'] as Map<String, dynamic>;
      for (final entry in averagesMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        averages[metric] = (entry.value as num).toDouble();
      }
    }
    
    if (json['peaks'] != null) {
      final peaksMap = json['peaks'] as Map<String, dynamic>;
      for (final entry in peaksMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        peaks[metric] = entry.value as int;
      }
    }
    
    if (json['previousPeriod'] != null) {
      final previousMap = json['previousPeriod'] as Map<String, dynamic>;
      for (final entry in previousMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        previousPeriod[metric] = entry.value as int;
      }
    }
    
    return AnalyticsSummary(
      period: period,
      totals: totals,
      averages: averages,
      peaks: peaks,
      previousPeriod: previousPeriod,
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'period': period.name,
      'totals': totals.map((key, value) => MapEntry(key.name, value)),
      'averages': averages.map((key, value) => MapEntry(key.name, value)),
      'peaks': peaks.map((key, value) => MapEntry(key.name, value)),
      'previousPeriod': previousPeriod.map((key, value) => MapEntry(key.name, value)),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
  
  int? getTotal(AnalyticsMetric metric) {
    return totals[metric];
  }
  
  double? getAverage(AnalyticsMetric metric) {
    return averages[metric];
  }
  
  int? getPeak(AnalyticsMetric metric) {
    return peaks[metric];
  }
  
  int? getPreviousPeriod(AnalyticsMetric metric) {
    return previousPeriod[metric];
  }
  
  double? getGrowthRate(AnalyticsMetric metric) {
    final current = totals[metric];
    final previous = previousPeriod[metric];
    
    if (current == null || previous == null || previous == 0) {
      return null;
    }
    
    return ((current - previous) / previous) * 100;
  }
}
