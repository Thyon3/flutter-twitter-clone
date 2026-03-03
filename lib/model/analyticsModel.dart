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

class TweetAnalytics {
  final String tweetId;
  final Map<AnalyticsMetric, int> metrics;
  final List<AnalyticsDataPoint> hourlyData;
  final List<AnalyticsDataPoint> dailyData;
  final Map<String, int> topCountries;
  final Map<String, int> topCities;
  final Map<String, int> topDevices;
  final Map<String, int> topSources;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  TweetAnalytics({
    required this.tweetId,
    required this.metrics,
    required this.hourlyData,
    required this.dailyData,
    required this.topCountries,
    required this.topCities,
    required this.topDevices,
    required this.topSources,
    required this.createdAt,
    required this.lastUpdated,
  });
  
  factory TweetAnalytics.fromJson(Map<String, dynamic> json) {
    final tweetId = json['tweetId'] as String;
    final metrics = <AnalyticsMetric, int>{};
    final hourlyData = <AnalyticsDataPoint>[];
    final dailyData = <AnalyticsDataPoint>[];
    final topCountries = <String, int>{};
    final topCities = <String, int>{};
    final topDevices = <String, int>{};
    final topSources = <String, int>{};
    
    if (json['metrics'] != null) {
      final metricsMap = json['metrics'] as Map<String, dynamic>;
      for (final entry in metricsMap.entries) {
        final metric = AnalyticsMetricExtension.fromString(entry.key);
        metrics[metric] = entry.value as int;
      }
    }
    
    if (json['hourlyData'] != null) {
      final hourlyList = json['hourlyData'] as List;
      for (final item in hourlyList) {
        hourlyData.add(AnalyticsDataPoint.fromJson(item));
      }
    }
    
    if (json['dailyData'] != null) {
      final dailyList = json['dailyData'] as List;
      for (final item in dailyList) {
        dailyData.add(AnalyticsDataPoint.fromJson(item));
      }
    }
    
    if (json['topCountries'] != null) {
      final countriesMap = json['topCountries'] as Map<String, dynamic>;
      for (final entry in countriesMap.entries) {
        topCountries[entry.key] = entry.value as int;
      }
    }
    
    if (json['topCities'] != null) {
      final citiesMap = json['topCities'] as Map<String, dynamic>;
      for (final entry in citiesMap.entries) {
        topCities[entry.key] = entry.value as int;
      }
    }
    
    if (json['topDevices'] != null) {
      final devicesMap = json['topDevices'] as Map<String, dynamic>;
      for (final entry in devicesMap.entries) {
        topDevices[entry.key] = entry.value as int;
      }
    }
    
    if (json['topSources'] != null) {
      final sourcesMap = json['topSources'] as Map<String, dynamic>;
      for (final entry in sourcesMap.entries) {
        topSources[entry.key] = entry.value as int;
      }
    }
    
    return TweetAnalytics(
      tweetId: tweetId,
      metrics: metrics,
      hourlyData: hourlyData,
      dailyData: dailyData,
      topCountries: topCountries,
      topCities: topCities,
      topDevices: topDevices,
      topSources: topSources,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'tweetId': tweetId,
      'metrics': metrics.map((key, value) => MapEntry(key.name, value)),
      'hourlyData': hourlyData.map((item) => item.toJson()).toList(),
      'dailyData': dailyData.map((item) => item.toJson()).toList(),
      'topCountries': topCountries,
      'topCities': topCities,
      'topDevices': topDevices,
      'topSources': topSources,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  int? getMetric(AnalyticsMetric metric) {
    return metrics[metric];
  }
  
  void setMetric(AnalyticsMetric metric, int value) {
    metrics[metric] = value;
  }
  
  List<AnalyticsDataPoint> getDataForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return hourlyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 1)))
        ).toList();
      case AnalyticsPeriod.week:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 7)))
        ).toList();
      case AnalyticsPeriod.month:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 30)))
        ).toList();
      case AnalyticsPeriod.quarter:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 90)))
        ).toList();
      case AnalyticsPeriod.year:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 365)))
        ).toList();
      case AnalyticsPeriod.all:
        return dailyData;
    }
  }
  
  double getEngagementRate() {
    final impressions = metrics[AnalyticsMetric.impressions] ?? 0;
    final engagements = metrics[AnalyticsMetric.engagements] ?? 0;
    
    if (impressions == 0) return 0.0;
    return (engagements / impressions) * 100;
  }
  
  Map<String, int> getTopCountries({int limit = 10}) {
    final sorted = Map.fromEntries(
      topCountries.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  Map<String, int> getTopCities({int limit = 10}) {
    final sorted = Map.fromEntries(
      topCities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  Map<String, int> getTopDevices({int limit = 5}) {
    final sorted = Map.fromEntries(
      topDevices.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  Map<String, int> getTopSources({int limit = 5}) {
    final sorted = Map.fromEntries(
      topSources.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
}

class UserAnalytics {
  final String userId;
  final Map<AnalyticsPeriod, AnalyticsSummary> summaries;
  final List<AnalyticsDataPoint> dailyData;
  final List<AnalyticsDataPoint> weeklyData;
  final List<AnalyticsDataPoint> monthlyData;
  final Map<String, TweetAnalytics> tweetAnalytics;
  final Map<String, int> topPerformingTweets;
  final Map<String, int> followerGrowth;
  final Map<String, int> engagementTrends;
  final Map<String, double> hashtagPerformance;
  final Map<String, int> mentionAnalytics;
  final DateTime createdAt;
  final DateTime lastUpdated;
  
  UserAnalytics({
    required this.userId,
    required this.summaries,
    required this.dailyData,
    required this.weeklyData,
    required this.monthlyData,
    required this.tweetAnalytics,
    required this.topPerformingTweets,
    required this.followerGrowth,
    required this.engagementTrends,
    required this.hashtagPerformance,
    required this.mentionAnalytics,
    required this.createdAt,
    required this.lastUpdated,
  });
  
  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'] as String;
    final summaries = <AnalyticsPeriod, AnalyticsSummary>{};
    final dailyData = <AnalyticsDataPoint>[];
    final weeklyData = <AnalyticsDataPoint>[];
    final monthlyData = <AnalyticsDataPoint>[];
    final tweetAnalytics = <String, TweetAnalytics>{};
    final topPerformingTweets = <String, int>{};
    final followerGrowth = <String, int>{};
    final engagementTrends = <String, int>{};
    final hashtagPerformance = <String, double>{};
    final mentionAnalytics = <String, int>{};
    
    if (json['summaries'] != null) {
      final summariesMap = json['summaries'] as Map<String, dynamic>;
      for (final entry in summariesMap.entries) {
        final period = AnalyticsPeriodExtension.fromString(entry.key);
        summaries[period] = AnalyticsSummary.fromJson(entry.value);
      }
    }
    
    if (json['dailyData'] != null) {
      final dailyList = json['dailyData'] as List;
      for (final item in dailyList) {
        dailyData.add(AnalyticsDataPoint.fromJson(item));
      }
    }
    
    if (json['weeklyData'] != null) {
      final weeklyList = json['weeklyData'] as List;
      for (final item in weeklyList) {
        weeklyData.add(AnalyticsDataPoint.fromJson(item));
      }
    }
    
    if (json['monthlyData'] != null) {
      final monthlyList = json['monthlyData'] as List;
      for (final item in monthlyList) {
        monthlyData.add(AnalyticsDataPoint.fromJson(item));
      }
    }
    
    if (json['tweetAnalytics'] != null) {
      final tweetsMap = json['tweetAnalytics'] as Map<String, dynamic>;
      for (final entry in tweetsMap.entries) {
        tweetAnalytics[entry.key] = TweetAnalytics.fromJson(entry.value);
      }
    }
    
    if (json['topPerformingTweets'] != null) {
      final topTweetsMap = json['topPerformingTweets'] as Map<String, dynamic>;
      for (final entry in topTweetsMap.entries) {
        topPerformingTweets[entry.key] = entry.value as int;
      }
    }
    
    if (json['followerGrowth'] != null) {
      final growthMap = json['followerGrowth'] as Map<String, dynamic>;
      for (final entry in growthMap.entries) {
        followerGrowth[entry.key] = entry.value as int;
      }
    }
    
    if (json['engagementTrends'] != null) {
      final trendsMap = json['engagementTrends'] as Map<String, dynamic>;
      for (final entry in trendsMap.entries) {
        engagementTrends[entry.key] = entry.value as int;
      }
    }
    
    if (json['hashtagPerformance'] != null) {
      final hashtagMap = json['hashtagPerformance'] as Map<String, dynamic>;
      for (final entry in hashtagMap.entries) {
        hashtagPerformance[entry.key] = (entry.value as num).toDouble();
      }
    }
    
    if (json['mentionAnalytics'] != null) {
      final mentionMap = json['mentionAnalytics'] as Map<String, dynamic>;
      for (final entry in mentionMap.entries) {
        mentionAnalytics[entry.key] = entry.value as int;
      }
    }
    
    return UserAnalytics(
      userId: userId,
      summaries: summaries,
      dailyData: dailyData,
      weeklyData: weeklyData,
      monthlyData: monthlyData,
      tweetAnalytics: tweetAnalytics,
      topPerformingTweets: topPerformingTweets,
      followerGrowth: followerGrowth,
      engagementTrends: engagementTrends,
      hashtagPerformance: hashtagPerformance,
      mentionAnalytics: mentionAnalytics,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'summaries': summaries.map((key, value) => MapEntry(key.name, value.toJson())),
      'dailyData': dailyData.map((item) => item.toJson()).toList(),
      'weeklyData': weeklyData.map((item) => item.toJson()).toList(),
      'monthlyData': monthlyData.map((item) => item.toJson()).toList(),
      'tweetAnalytics': tweetAnalytics.map((key, value) => MapEntry(key, value.toJson())),
      'topPerformingTweets': topPerformingTweets,
      'followerGrowth': followerGrowth,
      'engagementTrends': engagementTrends,
      'hashtagPerformance': hashtagPerformance,
      'mentionAnalytics': mentionAnalytics,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  AnalyticsSummary? getSummary(AnalyticsPeriod period) {
    return summaries[period];
  }
  
  List<AnalyticsDataPoint> getDataForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 1)))
        ).toList();
      case AnalyticsPeriod.week:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 7)))
        ).toList();
      case AnalyticsPeriod.month:
        return dailyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 30)))
        ).toList();
      case AnalyticsPeriod.quarter:
        return weeklyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 90)))
        ).toList();
      case AnalyticsPeriod.year:
        return monthlyData.where((point) => 
          point.timestamp.isAfter(DateTime.now().subtract(Duration(days: 365)))
        ).toList();
      case AnalyticsPeriod.all:
        return monthlyData;
    }
  }
  
  TweetAnalytics? getTweetAnalytics(String tweetId) {
    return tweetAnalytics[tweetId];
  }
  
  void addTweetAnalytics(String tweetId, TweetAnalytics analytics) {
    tweetAnalytics[tweetId] = analytics;
  }
  
  Map<String, int> getTopPerformingTweets({int limit = 10}) {
    final sorted = Map.fromEntries(
      topPerformingTweets.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  double getAverageEngagementRate() {
    if (tweetAnalytics.isEmpty) return 0.0;
    
    final totalRate = tweetAnalytics.values
        .map((analytics) => analytics.getEngagementRate())
        .reduce((a, b) => a + b);
    
    return totalRate / tweetAnalytics.length;
  }
  
  double getFollowerGrowthRate(AnalyticsPeriod period) {
    final summary = summaries[period];
    if (summary == null) return 0.0;
    
    return summary.getGrowthRate(AnalyticsMetric.followers) ?? 0.0;
  }
  
  Map<String, double> getTopHashtags({int limit = 10}) {
    final sorted = Map.fromEntries(
      hashtagPerformance.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  Map<String, int> getTopMentions({int limit = 10}) {
    final sorted = Map.fromEntries(
      mentionAnalytics.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
    return Map.fromEntries(sorted.entries.take(limit));
  }
  
  List<AnalyticsDataPoint> getFollowerGrowthData({int days = 30}) {
    return followerGrowth.entries
        .map((entry) => AnalyticsDataPoint(
              timestamp: DateTime.parse(entry.key),
              values: {AnalyticsMetric.followers: entry.value},
            ))
        .where((point) => point.timestamp.isAfter(DateTime.now().subtract(Duration(days: days))))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  List<AnalyticsDataPoint> getEngagementTrendData({int days = 30}) {
    return engagementTrends.entries
        .map((entry) => AnalyticsDataPoint(
              timestamp: DateTime.parse(entry.key),
              values: {AnalyticsMetric.engagements: entry.value},
            ))
        .where((point) => point.timestamp.isAfter(DateTime.now().subtract(Duration(days: days))))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
