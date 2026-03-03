import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/analyticsModel.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/state/appState.dart';

class AnalyticsState extends AppState {
  final DatabaseReference _analyticsReference = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  
  // Analytics data
  UserAnalytics? _userAnalytics;
  Map<String, TweetAnalytics> _tweetAnalytics = {};
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;
  AnalyticsChartType _selectedChartType = AnalyticsChartType.line;
  List<AnalyticsMetric> _selectedMetrics = [
    AnalyticsMetric.impressions,
    AnalyticsMetric.engagements,
    AnalyticsMetric.likes,
  ];
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  UserAnalytics? get userAnalytics => _userAnalytics;
  Map<String, TweetAnalytics> get tweetAnalytics => Map.from(_tweetAnalytics);
  AnalyticsPeriod get selectedPeriod => _selectedPeriod;
  AnalyticsChartType get selectedChartType => _selectedChartType;
  List<AnalyticsMetric> get selectedMetrics => List.from(_selectedMetrics);
  
  /// Initialize analytics state
  Future<void> initialize() async {
    await Future.wait([
      loadUserAnalytics(),
      loadTweetAnalytics(),
    ]);
  }
  
  /// Load user analytics from Firebase
  Future<void> loadUserAnalytics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _analyticsReference
          .child('userAnalytics')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        _userAnalytics = UserAnalytics.fromJson(snapshot.value as Map<String, dynamic>);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user analytics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load tweet analytics from Firebase
  Future<void> loadTweetAnalytics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _analyticsReference
          .child('tweetAnalytics')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final tweetsMap = snapshot.value as Map<String, dynamic>;
        for (final entry in tweetsMap.entries) {
          _tweetAnalytics[entry.key] = TweetAnalytics.fromJson(entry.value);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tweet analytics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Generate analytics for a specific tweet
  Future<void> generateTweetAnalytics(String tweetId, FeedModel tweet) async {
    try {
      _isGenerating = true;
      _error = null;
      notifyListeners();
      
      // Simulate analytics generation
      await Future.delayed(Duration(seconds: 2));
      
      final metrics = {
        AnalyticsMetric.impressions: _generateRandomValue(100, 10000),
        AnalyticsMetric.engagements: _generateRandomValue(10, 500),
        AnalyticsMetric.likes: _generateRandomValue(5, 200),
        AnalyticsMetric.retweets: _generateRandomValue(1, 50),
        AnalyticsMetric.replies: _generateRandomValue(1, 30),
        AnalyticsMetric.profileViews: _generateRandomValue(5, 100),
        AnalyticsMetric.linkClicks: _generateRandomValue(0, 50),
        AnalyticsMetric.mentions: _generateRandomValue(0, 20),
        AnalyticsMetric.quoteTweets: _generateRandomValue(0, 15),
        AnalyticsMetric.bookmarks: _generateRandomValue(0, 25),
        AnalyticsMetric.mediaViews: _generateRandomValue(10, 500),
      };
      
      final hourlyData = _generateHourlyData(24, metrics);
      final dailyData = _generateDailyData(30, metrics);
      
      final tweetAnalytics = TweetAnalytics(
        tweetId: tweetId,
        metrics: metrics,
        hourlyData: hourlyData,
        dailyData: dailyData,
        topCountries: _generateTopCountries(),
        topCities: _generateTopCities(),
        topDevices: _generateTopDevices(),
        topSources: _generateTopSources(),
        createdAt: DateTime.parse(tweet.createdAt!),
        lastUpdated: DateTime.now(),
      );
      
      _tweetAnalytics[tweetId] = tweetAnalytics;
      
      // Save to Firebase
      await _saveTweetAnalytics(tweetId, tweetAnalytics);
      
      _isGenerating = false;
      notifyListeners();
      
      cprint('Tweet analytics generated for $tweetId', event: 'generate_tweet_analytics');
    } catch (e) {
      _error = 'Failed to generate tweet analytics: $e';
      _isGenerating = false;
      notifyListeners();
    }
  }
  
  /// Generate comprehensive user analytics
  Future<void> generateUserAnalytics() async {
    try {
      _isGenerating = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Simulate analytics generation
      await Future.delayed(Duration(seconds: 3));
      
      final summaries = <AnalyticsPeriod, AnalyticsSummary>{};
      final periods = AnalyticsPeriod.values;
      
      for (final period in periods) {
        summaries[period] = _generateSummary(period);
      }
      
      final dailyData = _generateDailyData(90, {
        AnalyticsMetric.impressions: 0,
        AnalyticsMetric.engagements: 0,
        AnalyticsMetric.likes: 0,
        AnalyticsMetric.retweets: 0,
        AnalyticsMetric.replies: 0,
        AnalyticsMetric.followers: 0,
        AnalyticsMetric.tweets: 0,
      });
      
      final weeklyData = _generateWeeklyData(52, {
        AnalyticsMetric.impressions: 0,
        AnalyticsMetric.engagements: 0,
        AnalyticsMetric.likes: 0,
        AnalyticsMetric.retweets: 0,
        AnalyticsMetric.replies: 0,
        AnalyticsMetric.followers: 0,
        AnalyticsMetric.tweets: 0,
      });
      
      final monthlyData = _generateMonthlyData(24, {
        AnalyticsMetric.impressions: 0,
        AnalyticsMetric.engagements: 0,
        AnalyticsMetric.likes: 0,
        AnalyticsMetric.retweets: 0,
        AnalyticsMetric.replies: 0,
        AnalyticsMetric.followers: 0,
        AnalyticsMetric.tweets: 0,
      });
      
      _userAnalytics = UserAnalytics(
        userId: userId,
        summaries: summaries,
        dailyData: dailyData,
        weeklyData: weeklyData,
        monthlyData: monthlyData,
        tweetAnalytics: _tweetAnalytics,
        topPerformingTweets: _generateTopPerformingTweets(),
        followerGrowth: _generateFollowerGrowth(),
        engagementTrends: _generateEngagementTrends(),
        hashtagPerformance: _generateHashtagPerformance(),
        mentionAnalytics: _generateMentionAnalytics(),
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      
      // Save to Firebase
      await _saveUserAnalytics();
      
      _isGenerating = false;
      notifyListeners();
      
      cprint('User analytics generated', event: 'generate_user_analytics');
    } catch (e) {
      _error = 'Failed to generate user analytics: $e';
      _isGenerating = false;
      notifyListeners();
    }
  }
  
  /// Set selected period
  void setSelectedPeriod(AnalyticsPeriod period) {
    _selectedPeriod = period;
    notifyListeners();
  }
  
  /// Set selected chart type
  void setSelectedChartType(AnalyticsChartType chartType) {
    _selectedChartType = chartType;
    notifyListeners();
  }
  
  /// Set selected metrics
  void setSelectedMetrics(List<AnalyticsMetric> metrics) {
    _selectedMetrics = List.from(metrics);
    notifyListeners();
  }
  
  /// Add metric to selection
  void addMetric(AnalyticsMetric metric) {
    if (!_selectedMetrics.contains(metric)) {
      _selectedMetrics.add(metric);
      notifyListeners();
    }
  }
  
  /// Remove metric from selection
  void removeMetric(AnalyticsMetric metric) {
    _selectedMetrics.remove(metric);
    notifyListeners();
  }
  
  /// Get analytics data for current period and metrics
  List<AnalyticsDataPoint> getChartData() {
    if (_userAnalytics == null) return [];
    
    final data = _userAnalytics!.getDataForPeriod(_selectedPeriod);
    
    // Filter data based on selected metrics
    return data.map((point) {
      final filteredValues = <AnalyticsMetric, int>{};
      for (final metric in _selectedMetrics) {
        filteredValues[metric] = point.getValue(metric) ?? 0;
      }
      return AnalyticsDataPoint(
        timestamp: point.timestamp,
        values: filteredValues,
      );
    }).toList();
  }
  
  /// Get summary for current period
  AnalyticsSummary? getCurrentSummary() {
    if (_userAnalytics == null) return null;
    return _userAnalytics!.getSummary(_selectedPeriod);
  }
  
  /// Refresh analytics data
  Future<void> refreshAnalytics() async {
    await Future.wait([
      loadUserAnalytics(),
      loadTweetAnalytics(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Private helper methods
  
  int _generateRandomValue(int min, int max) {
    return min + (DateTime.now().millisecond % (max - min));
  }
  
  List<AnalyticsDataPoint> _generateHourlyData(int hours, Map<AnalyticsMetric, int> baseMetrics) {
    final data = <AnalyticsDataPoint>[];
    final now = DateTime.now();
    
    for (int i = 0; i < hours; i++) {
      final timestamp = now.subtract(Duration(hours: hours - i - 1));
      final values = <AnalyticsMetric, int>{};
      
      for (final metric in baseMetrics.keys) {
        final baseValue = baseMetrics[metric] ?? 0;
        final variation = (baseValue * 0.3 * (DateTime.now().millisecond % 100) / 100).round();
        values[metric] = (baseValue * (i + 1) / hours + variation).round();
      }
      
      data.add(AnalyticsDataPoint(timestamp: timestamp, values: values));
    }
    
    return data;
  }
  
  List<AnalyticsDataPoint> _generateDailyData(int days, Map<AnalyticsMetric, int> baseMetrics) {
    final data = <AnalyticsDataPoint>[];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final timestamp = now.subtract(Duration(days: days - i - 1));
      final values = <AnalyticsMetric, int>{};
      
      for (final metric in baseMetrics.keys) {
        final baseValue = baseMetrics[metric] ?? 0;
        final variation = (baseValue * 0.5 * (DateTime.now().millisecond % 100) / 100).round();
        values[metric] = (baseValue * (i + 1) / days + variation).round();
      }
      
      data.add(AnalyticsDataPoint(timestamp: timestamp, values: values));
    }
    
    return data;
  }
  
  List<AnalyticsDataPoint> _generateWeeklyData(int weeks, Map<AnalyticsMetric, int> baseMetrics) {
    final data = <AnalyticsDataPoint>[];
    final now = DateTime.now();
    
    for (int i = 0; i < weeks; i++) {
      final timestamp = now.subtract(Duration(days: (weeks - i - 1) * 7));
      final values = <AnalyticsMetric, int>{};
      
      for (final metric in baseMetrics.keys) {
        final baseValue = baseMetrics[metric] ?? 0;
        final variation = (baseValue * 0.6 * (DateTime.now().millisecond % 100) / 100).round();
        values[metric] = (baseValue * (i + 1) / weeks + variation).round();
      }
      
      data.add(AnalyticsDataPoint(timestamp: timestamp, values: values));
    }
    
    return data;
  }
  
  List<AnalyticsDataPoint> _generateMonthlyData(int months, Map<AnalyticsMetric, int> baseMetrics) {
    final data = <AnalyticsDataPoint>[];
    final now = DateTime.now();
    
    for (int i = 0; i < months; i++) {
      final timestamp = DateTime(now.year, now.month - (months - i - 1), 1);
      final values = <AnalyticsMetric, int>{};
      
      for (final metric in baseMetrics.keys) {
        final baseValue = baseMetrics[metric] ?? 0;
        final variation = (baseValue * 0.7 * (DateTime.now().millisecond % 100) / 100).round();
        values[metric] = (baseValue * (i + 1) / months + variation).round();
      }
      
      data.add(AnalyticsDataPoint(timestamp: timestamp, values: values));
    }
    
    return data;
  }
  
  AnalyticsSummary _generateSummary(AnalyticsPeriod period) {
    final totals = <AnalyticsMetric, int>{};
    final averages = <AnalyticsMetric, double>{};
    final peaks = <AnalyticsMetric, int>{};
    final previousPeriod = <AnalyticsMetric, int>{};
    
    final metrics = AnalyticsMetric.values;
    for (final metric in metrics) {
      totals[metric] = _generateRandomValue(100, 10000);
      averages[metric] = totals[metric]! / 30.0;
      peaks[metric] = (totals[metric]! * 1.5).round();
      previousPeriod[metric] = (totals[metric]! * 0.8).round();
    }
    
    return AnalyticsSummary(
      period: period,
      totals: totals,
      averages: averages,
      peaks: peaks,
      previousPeriod: previousPeriod,
      generatedAt: DateTime.now(),
    );
  }
  
  Map<String, int> _generateTopCountries() {
    return {
      'United States': 4500,
      'United Kingdom': 2300,
      'Canada': 1800,
      'Australia': 1200,
      'Germany': 980,
      'France': 850,
      'India': 720,
      'Brazil': 650,
      'Japan': 580,
      'Netherlands': 420,
    };
  }
  
  Map<String, int> _generateTopCities() {
    return {
      'New York': 1200,
      'London': 980,
      'Los Angeles': 850,
      'Toronto': 720,
      'Sydney': 650,
      'Chicago': 580,
      'San Francisco': 520,
      'Berlin': 480,
      'Paris': 420,
      'Melbourne': 380,
    };
  }
  
  Map<String, int> _generateTopDevices() {
    return {
      'iPhone': 3500,
      'Android': 2800,
      'Web': 2200,
      'iPad': 1200,
      'Android Tablet': 800,
    };
  }
  
  Map<String, int> _generateTopSources() {
    return {
      'Twitter Web': 4200,
      'Twitter iOS': 3800,
      'Twitter Android': 3200,
      'TweetDeck': 1500,
      'Third Party': 800,
    };
  }
  
  Map<String, int> _generateTopPerformingTweets() {
    final tweets = <String, int>{};
    for (int i = 0; i < 10; i++) {
      tweets['tweet_$i'] = _generateRandomValue(100, 5000);
    }
    return tweets;
  }
  
  Map<String, int> _generateFollowerGrowth() {
    final growth = <String, int>{};
    final now = DateTime.now();
    int currentFollowers = 1000;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      final dailyGrowth = _generateRandomValue(-5, 50);
      currentFollowers += dailyGrowth;
      growth[date.toIso8601String()] = currentFollowers;
    }
    
    return growth;
  }
  
  Map<String, int> _generateEngagementTrends() {
    final trends = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      trends[date.toIso8601String()] = _generateRandomValue(50, 500);
    }
    
    return trends;
  }
  
  Map<String, double> _generateHashtagPerformance() {
    return {
      '#flutter': 85.5,
      '#dart': 72.3,
      '#mobiledev': 68.9,
      '#programming': 65.2,
      '#tech': 58.7,
      '#coding': 54.3,
      '#developer': 48.9,
      '#appdev': 45.6,
      '#ui': 42.1,
      '#ux': 38.7,
    };
  }
  
  Map<String, int> _generateMentionAnalytics() {
    return {
      '@flutter': 120,
      '@dartlang': 85,
      '@googledev': 72,
      '@github': 65,
      '@stackoverflow': 58,
      '@medium': 45,
      '@devto': 38,
      '@producthunt': 32,
      '@hackernews': 28,
      '@reddit': 25,
    };
  }
  
  Future<void> _saveTweetAnalytics(String tweetId, TweetAnalytics analytics) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    await _analyticsReference
        .child('tweetAnalytics')
        .child(userId)
        .child(tweetId)
        .set(analytics.toJson());
  }
  
  Future<void> _saveUserAnalytics() async {
    if (_userAnalytics == null) return;
    
    await _analyticsReference
        .child('userAnalytics')
        .child(_userAnalytics!.userId)
        .set(_userAnalytics!.toJson());
  }
}
