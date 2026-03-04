import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/securityModel.dart';
import 'package:twitterclone/model/securitySessionModel.dart';
import 'package:twitterclone/model/securityDeviceModel.dart';
import 'package:twitterclone/model/securityThreatModel.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/state/appState.dart';

class SecurityState extends AppState {
  final DatabaseReference _securityReference = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  
  // Security events and sessions
  List<SecurityEvent> _events = [];
  List<SecuritySession> _sessions = [];
  List<SecurityDevice> _devices = [];
  List<SecurityThreat> _threats = [];
  
  // Current session
  SecuritySession? _currentSession;
  SecurityDevice? _currentDevice;
  
  // Settings
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = true;
  bool _deviceVerificationEnabled = true;
  bool _suspiciousActivityDetection = true;
  int _maxSessions = 5;
  int _sessionTimeoutMinutes = 30;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<SecurityEvent> get events => List.from(_events);
  List<SecuritySession> get sessions => List.from(_sessions);
  List<SecurityDevice> get devices => List.from(_devices);
  List<SecurityThreat> get threats => List.from(_threats);
  SecuritySession? get currentSession => _currentSession;
  SecurityDevice? get currentDevice => _currentDevice;
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get loginAlertsEnabled => _loginAlertsEnabled;
  bool get deviceVerificationEnabled => _deviceVerificationEnabled;
  bool get suspiciousActivityDetection => _suspiciousActivityDetection;
  int get maxSessions => _maxSessions;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  
  // Computed properties
  List<SecurityEvent> get criticalEvents => _events.where((e) => e.isCritical).toList();
  
  List<SecurityEvent> get unresolvedEvents => _events.where((e) => !e.isResolved).toList();
  
  List<SecuritySession> get activeSessions => _sessions.where((s) => s.isActive).toList();
  
  List<SecurityDevice> get trustedDevices => _devices.where((d) => d.isTrusted).toList();
  
  List<SecurityThreat> get activeThreats => _threats.where((t) => t.isActive).toList();
  
  List<SecurityThreat> get criticalThreats => _threats.where((t) => t.isCritical).toList();
  
  int get activeSessionCount => activeSessions.length;
  
  int get trustedDeviceCount => trustedDevices.length;
  
  int get unresolvedEventCount => unresolvedEvents.length;
  
  int get activeThreatCount => activeThreats.length;
  
  /// Initialize security state
  Future<void> initialize() async {
    await Future.wait([
      loadSecurityEvents(),
      loadSecuritySessions(),
      loadSecurityDevices(),
      loadSecurityThreats(),
      setupRealtimeListeners(),
    ]);
  }
  
  /// Load security events
  Future<void> loadSecurityEvents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _securityReference
          .child('events')
          .child(userId)
          .orderByChild('timestamp')
          .limitToLast(100)
          .get();
      
      if (snapshot.exists) {
        final eventsMap = snapshot.value as Map<String, dynamic>;
        _events = [];
        
        for (final entry in eventsMap.entries) {
          final event = SecurityEvent.fromJson(entry.value);
          _events.add(event);
        }
        
        // Sort by timestamp (newest first)
        _events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load security events: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load security sessions
  Future<void> loadSecuritySessions() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _securityReference
          .child('sessions')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final sessionsMap = snapshot.value as Map<String, dynamic>;
        _sessions = [];
        
        for (final entry in sessionsMap.entries) {
          final session = SecuritySession.fromJson(entry.value);
          _sessions.add(session);
        }
        
        // Sort by last activity (newest first)
        _sessions.sort((a, b) => (b.lastActivity ?? b.createdAt).compareTo(a.lastActivity ?? a.createdAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load security sessions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load security devices
  Future<void> loadSecurityDevices() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _securityReference
          .child('devices')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final devicesMap = snapshot.value as Map<String, dynamic>;
        _devices = [];
        
        for (final entry in devicesMap.entries) {
          final device = SecurityDevice.fromJson(entry.value);
          _devices.add(device);
        }
        
        // Sort by last seen (newest first)
        _devices.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load security devices: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load security threats
  Future<void> loadSecurityThreats() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _securityReference
          .child('threats')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final threatsMap = snapshot.value as Map<String, dynamic>;
        _threats = [];
        
        for (final entry in threatsMap.entries) {
          final threat = SecurityThreat.fromJson(entry.value);
          _threats.add(threat);
        }
        
        // Sort by detected at (newest first)
        _threats.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load security threats: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Setup real-time listeners
  Future<void> setupRealtimeListeners() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Listen for new security events
      _securityReference
          .child('events')
          .child(userId)
          .limitToLast(1)
          .onChildAdded
          .listen((event) {
        if (event.snapshot.exists) {
          final securityEvent = SecurityEvent.fromJson(event.snapshot.value as Map<String, dynamic>);
          _events.insert(0, securityEvent);
          
          // Keep only last 100 events
          if (_events.length > 100) {
            _events = _events.take(100).toList();
          }
          
          notifyListeners();
        }
      });
      
      cprint('Security listeners setup', event: 'security_listeners');
    } catch (e) {
      _error = 'Failed to setup security listeners: $e';
      notifyListeners();
    }
  }
  
  /// Create security event
  Future<void> createSecurityEvent({
    required SecurityEventType eventType,
    required SecurityLevel severity,
    String? description,
    String? ipAddress,
    String? userAgent,
    String? deviceId,
    String? location,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final eventId = _securityReference.child('events').child(userId).push().key!;
      
      final event = SecurityEvent(
        id: eventId,
        userId: userId,
        eventType: eventType,
        severity: severity,
        description: description,
        timestamp: DateTime.now(),
        ipAddress: ipAddress,
        userAgent: userAgent,
        deviceId: deviceId,
        location: location,
        metadata: metadata,
      );
      
      // Save to Firebase
      await _securityReference
          .child('events')
          .child(userId)
          .child(eventId)
          .set(event.toJson());
      
      // Add to local list
      _events.insert(0, event);
      
      // Keep only last 100 events
      if (_events.length > 100) {
        _events = _events.take(100).toList();
      }
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Security event created: $eventType', event: 'create_security_event');
    } catch (e) {
      _error = 'Failed to create security event: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Create security session
  Future<void> createSecuritySession({
    required String sessionId,
    required AuthenticationMethod authMethod,
    String? ipAddress,
    String? userAgent,
    String? deviceId,
    String? location,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final session = SecuritySession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        sessionId: sessionId,
        authMethod: authMethod,
        status: SessionStatus.active,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(minutes: _sessionTimeoutMinutes)),
        lastActivity: DateTime.now(),
        ipAddress: ipAddress,
        userAgent: userAgent,
        deviceId: deviceId,
        location: location,
        isCurrent: true,
      );
      
      // Save to Firebase
      await _securityReference
          .child('sessions')
          .child(userId)
          .child(session.id)
          .set(session.toJson());
      
      // Add to local list
      _sessions.insert(0, session);
      
      // Set as current session
      _currentSession = session;
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Security session created: $sessionId', event: 'create_security_session');
    } catch (e) {
      _error = 'Failed to create security session: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Terminate session
  Future<void> terminateSession(String sessionId, String reason) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final sessionIndex = _sessions.indexWhere((s) => s.sessionId == sessionId);
      if (sessionIndex == -1) return;
      
      final session = _sessions[sessionIndex];
      session.terminate(reason);
      
      // Update in Firebase
      await _securityReference
          .child('sessions')
          .child(userId)
          .child(session.id)
          .update({
        'status': session.status.name,
        'events': session.events.map((e) => e.toJson()).toList(),
      });
      
      // Update local list
      _sessions[sessionIndex] = session;
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Session terminated: $sessionId', event: 'terminate_session');
    } catch (e) {
      _error = 'Failed to terminate session: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Block device
  Future<void> blockDevice(String deviceId, String reason) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final deviceIndex = _devices.indexWhere((d) => d.deviceId == deviceId);
      if (deviceIndex == -1) return;
      
      final device = _devices[deviceIndex];
      device.block(reason);
      
      // Update in Firebase
      await _securityReference
          .child('devices')
          .child(userId)
          .child(device.id)
          .update({
        'isBlocked': true,
        'blockedAt': device.blockedAt!.toIso8601String(),
        'blockedReason': reason,
        'isActive': false,
      });
      
      // Update local list
      _devices[deviceIndex] = device;
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Device blocked: $deviceId', event: 'block_device');
    } catch (e) {
      _error = 'Failed to block device: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Resolve threat
  Future<void> resolveThreat(String threatId, SecurityAction action, String? reason) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final threatIndex = _threats.indexWhere((t) => t.id == threatId);
      if (threatIndex == -1) return;
      
      final threat = _threats[threatIndex];
      threat.resolve(userId, action, reason);
      
      // Update in Firebase
      await _securityReference
          .child('threats')
          .child(userId)
          .child(threatId)
          .update({
        'isResolved': true,
        'isActive': false,
        'resolvedAt': threat.resolvedAt!.toIso8601String(),
        'resolvedBy': userId,
        'actionTaken': action.name,
        'actionReason': reason,
      });
      
      // Update local list
      _threats[threatIndex] = threat;
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Threat resolved: $threatId', event: 'resolve_threat');
    } catch (e) {
      _error = 'Failed to resolve threat: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Toggle two-factor authentication
  void toggleTwoFactor() {
    _twoFactorEnabled = !_twoFactorEnabled;
    notifyListeners();
  }
  
  /// Toggle login alerts
  void toggleLoginAlerts() {
    _loginAlertsEnabled = !_loginAlertsEnabled;
    notifyListeners();
  }
  
  /// Toggle device verification
  void toggleDeviceVerification() {
    _deviceVerificationEnabled = !_deviceVerificationEnabled;
    notifyListeners();
  }
  
  /// Toggle suspicious activity detection
  void toggleSuspiciousActivityDetection() {
    _suspiciousActivityDetection = !_suspiciousActivityDetection;
    notifyListeners();
  }
  
  /// Update max sessions
  void updateMaxSessions(int maxSessions) {
    _maxSessions = maxSessions;
    notifyListeners();
  }
  
  /// Update session timeout
  void updateSessionTimeout(int minutes) {
    _sessionTimeoutMinutes = minutes;
    notifyListeners();
  }
  
  /// Get events by type
  List<SecurityEvent> getEventsByType(SecurityEventType type) {
    return _events.where((e) => e.eventType == type).toList();
  }
  
  /// Get events by severity
  List<SecurityEvent> getEventsBySeverity(SecurityLevel severity) {
    return _events.where((e) => e.severity == severity).toList();
  }
  
  /// Search events
  List<SecurityEvent> searchEvents(String query) {
    if (query.isEmpty) return _events;
    
    final lowerQuery = query.toLowerCase();
    return _events.where((e) =>
      e.description?.toLowerCase().contains(lowerQuery) == true ||
      e.ipAddress?.toLowerCase().contains(lowerQuery) == true ||
      e.location?.toLowerCase().contains(lowerQuery) == true
    ).toList();
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadSecurityEvents(),
      loadSecuritySessions(),
      loadSecurityDevices(),
      loadSecurityThreats(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
