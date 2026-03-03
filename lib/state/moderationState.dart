import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/moderationModel.dart';
import 'package:twitterclone/model/moderationFilterModel.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/state/appState.dart';

class ModerationState extends AppState {
  final DatabaseReference _moderationReference = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  
  // Reports and queues
  List<ContentReport> _reports = [];
  List<ModerationQueue> _queues = [];
  ContentReport? _currentReport;
  ModerationQueue? _currentQueue;
  
  // Filter rules
  List<ModerationFilterRule> _filterRules = [];
  List<FilterResult> _filterResults = [];
  
  // Statistics
  Map<String, int> _statistics = {};
  Map<String, dynamic> _dashboardMetrics = {};
  
  // Settings
  bool _autoModerationEnabled = true;
  List<ModerationFilter> _activeFilters = [];
  ModerationPriority _defaultPriority = ModerationPriority.normal;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<ContentReport> get reports => List.from(_reports);
  List<ModerationQueue> get queues => List.from(_queues);
  ContentReport? get currentReport => _currentReport;
  ModerationQueue? get currentQueue => _currentQueue;
  List<ModerationFilterRule> get filterRules => List.from(_filterRules);
  List<FilterResult> get filterResults => List.from(_filterResults);
  Map<String, int> get statistics => Map.from(_statistics);
  Map<String, dynamic> get dashboardMetrics => Map.from(_dashboardMetrics);
  bool get autoModerationEnabled => _autoModerationEnabled;
  List<ModerationFilter> get activeFilters => List.from(_activeFilters);
  ModerationPriority get defaultPriority => _defaultPriority;
  
  // Computed properties
  List<ContentReport> get pendingReports => _reports.where((r) => r.status == ModerationStatus.pending).toList();
  
  List<ContentReport> get urgentReports => _reports.where((r) => r.priority == ModerationPriority.urgent).toList();
  
  List<ContentReport> get criticalReports => _reports.where((r) => r.severity == ModerationSeverity.critical).toList();
  
  int get pendingCount => pendingReports.length;
  
  int get urgentCount => urgentReports.length;
  
  int get criticalCount => criticalReports.length;
  
  /// Initialize moderation state
  Future<void> initialize() async {
    await Future.wait([
      loadReports(),
      loadQueues(),
      loadFilterRules(),
      loadStatistics(),
    ]);
  }
  
  /// Load all reports
  Future<void> loadReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final snapshot = await _moderationReference
          .child('reports')
          .get();
      
      if (snapshot.exists) {
        final reportsMap = snapshot.value as Map<String, dynamic>;
        _reports = [];
        
        for (final entry in reportsMap.entries) {
          final report = ContentReport.fromJson(entry.value);
          _reports.add(report);
        }
        
        // Sort by creation date (newest first)
        _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load moderation queues
  Future<void> loadQueues() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _moderationReference
          .child('queues')
          .get();
      
      if (snapshot.exists) {
        final queuesMap = snapshot.value as Map<String, dynamic>;
        _queues = [];
        
        for (final entry in queuesMap.entries) {
          final queue = ModerationQueue.fromJson(entry.value);
          _queues.add(queue);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load queues: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load filter rules
  Future<void> loadFilterRules() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _moderationReference
          .child('filterRules')
          .get();
      
      if (snapshot.exists) {
        final rulesMap = snapshot.value as Map<String, dynamic>;
        _filterRules = [];
        
        for (final entry in rulesMap.entries) {
          final rule = ModerationFilterRule.fromJson(entry.value);
          _filterRules.add(rule);
        }
        
        // Sort by priority (highest first)
        _filterRules.sort((a, b) => b.priority.compareTo(a.priority));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load filter rules: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _moderationReference
          .child('statistics')
          .get();
      
      if (snapshot.exists) {
        _statistics = Map<String, int>.from(snapshot.value);
      } else {
        _statistics = {
          'totalReports': 0,
          'pendingReports': 0,
          'resolvedReports': 0,
          'urgentReports': 0,
          'criticalReports': 0,
          'averageResolutionTime': 0,
          'reportsToday': 0,
          'reportsThisWeek': 0,
          'reportsThisMonth': 0,
        };
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load statistics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Create a new report
  Future<void> createReport({
    required String contentId,
    required ContentType contentType,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
    bool isAnonymous = false,
    List<String> evidenceUrls = const [],
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final reportId = _moderationReference.child('reports').push().key!;
      
      final report = ContentReport(
        id: reportId,
        reporterId: userId,
        reportedUserId: reportedUserId,
        contentId: contentId,
        contentType: contentType,
        reason: reason,
        description: description,
        severity: _getSeverityFromReason(reason),
        createdAt: DateTime.now(),
        isAnonymous: isAnonymous,
        evidenceUrls: evidenceUrls,
      );
      
      // Save report to Firebase
      await _moderationReference
          .child('reports')
          .child(reportId)
          .set(report.toJson());
      
      // Add to local list
      _reports.insert(0, report);
      
      // Update statistics
      _updateStatistics();
      
      // Run auto-moderation if enabled
      if (_autoModerationEnabled) {
        await _runAutoModeration(report);
      }
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Report created: $reportId', event: 'create_report');
    } catch (e) {
      _error = 'Failed to create report: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Process a report (take action)
  Future<void> processReport({
    required String reportId,
    required ModerationAction action,
    String? reason,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) return;
      
      final report = _reports[reportIndex];
      
      // Update report with action
      report.takeAction(action, reason, userId);
      
      // Save to Firebase
      await _moderationReference
          .child('reports')
          .child(reportId)
          .set(report.toJson());
      
      // Update local list
      _reports[reportIndex] = report;
      
      // Update statistics
      _updateStatistics();
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Report processed: $reportId', event: 'process_report');
    } catch (e) {
      _error = 'Failed to process report: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Set current report for detailed view
  void setCurrentReport(ContentReport? report) {
    _currentReport = report;
    notifyListeners();
  }
  
  /// Set current queue
  void setCurrentQueue(ModerationQueue? queue) {
    _currentQueue = queue;
    notifyListeners();
  }
  
  /// Toggle auto-moderation
  void toggleAutoModeration() {
    _autoModerationEnabled = !_autoModerationEnabled;
    notifyListeners();
  }
  
  /// Add active filter
  void addActiveFilter(ModerationFilter filter) {
    if (!_activeFilters.contains(filter)) {
      _activeFilters.add(filter);
      notifyListeners();
    }
  }
  
  /// Remove active filter
  void removeActiveFilter(ModerationFilter filter) {
    _activeFilters.remove(filter);
    notifyListeners();
  }
  
  /// Set default priority
  void setDefaultPriority(ModerationPriority priority) {
    _defaultPriority = priority;
    notifyListeners();
  }
  
  /// Get reports by status
  List<ContentReport> getReportsByStatus(ModerationStatus status) {
    return _reports.where((r) => r.status == status).toList();
  }
  
  /// Get reports by priority
  List<ContentReport> getReportsByPriority(ModerationPriority priority) {
    return _reports.where((r) => r.priority == priority).toList();
  }
  
  /// Get reports by severity
  List<ContentReport> getReportsBySeverity(ModerationSeverity severity) {
    return _reports.where((r) => r.severity == severity).toList();
  }
  
  /// Get reports by content type
  List<ContentReport> getReportsByContentType(ContentType contentType) {
    return _reports.where((r) => r.contentType == contentType).toList();
  }
  
  /// Search reports
  List<ContentReport> searchReports(String query) {
    if (query.isEmpty) return _reports;
    
    final lowerQuery = query.toLowerCase();
    return _reports.where((r) =>
      r.contentId.toLowerCase().contains(lowerQuery) ||
      r.reportedUserId.toLowerCase().contains(lowerQuery) ||
      (r.description?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadReports(),
      loadQueues(),
      loadFilterRules(),
      loadStatistics(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Private helper methods
  
  ModerationSeverity _getSeverityFromReason(ReportReason reason) {
    switch (reason.severityLevel) {
      case 1:
      case 2:
        return ModerationSeverity.low;
      case 3:
      case 4:
        return ModerationSeverity.medium;
      case 5:
      case 6:
        return ModerationSeverity.high;
      case 7:
      case 8:
      case 9:
      case 10:
        return ModerationSeverity.critical;
      default:
        return ModerationSeverity.medium;
    }
  }
  
  Future<void> _runAutoModeration(ContentReport report) async {
    // This would run filter rules against the reported content
    // For now, just log that auto-moderation was triggered
    cprint('Auto-moderation triggered for report: ${report.id}', event: 'auto_moderation');
  }
  
  Future<void> _updateStatistics() async {
    _statistics['totalReports'] = _reports.length;
    _statistics['pendingReports'] = pendingCount;
    _statistics['urgentReports'] = urgentCount;
    _statistics['criticalReports'] = criticalCount;
    
    final resolved = _reports.where((r) => r.isReviewed).length;
    _statistics['resolvedReports'] = resolved;
    
    // Save to Firebase
    await _moderationReference
        .child('statistics')
        .set(_statistics);
  }
}
