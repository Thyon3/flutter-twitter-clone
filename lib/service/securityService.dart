import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/securityModel.dart';
import 'package:twitterclone/model/securitySessionModel.dart';
import 'package:twitterclone/model/securityDeviceModel.dart';
import 'package:twitterclone/model/securityThreatModel.dart';
import 'package:twitterclone/helper/utility.dart';

class SecurityService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  SecurityService();
  
  /// Detect suspicious login patterns
  Future<List<SecurityThreat>> detectSuspiciousLogin({
    required String userId,
    required String ipAddress,
    required String userAgent,
    required String deviceId,
  }) async {
    final threats = <SecurityThreat>[];
    
    try {
      // Check for multiple failed login attempts
      final failedAttempts = await _getFailedLoginAttempts(userId, ipAddress);
      if (failedAttempts >= 5) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: ThreatType.bruteForce,
          severity: SecurityLevel.high,
          title: 'Multiple Failed Login Attempts',
          description: 'Detected $failedAttempts failed login attempts from IP $ipAddress',
          userId: userId,
          ipAddress: ipAddress,
          detectedAt: DateTime.now(),
          evidence: {'failedAttempts': failedAttempts, 'ipAddress': ipAddress},
          recommendedAction: SecurityAction.block,
        ));
      }
      
      // Check for unusual location
      final isUnusualLocation = await _isUnusualLocation(userId, ipAddress);
      if (isUnusualLocation) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_1',
          type: ThreatType.suspiciousLogin,
          severity: SecurityLevel.medium,
          title: 'Unusual Login Location',
          description: 'Login from unusual location detected',
          userId: userId,
          ipAddress: ipAddress,
          detectedAt: DateTime.now(),
          evidence: {'ipAddress': ipAddress, 'location': 'Unknown'},
          recommendedAction: SecurityAction.requireVerification,
        ));
      }
      
      // Check for new device
      final isNewDevice = await _isNewDevice(userId, deviceId);
      if (isNewDevice) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_2',
          type: ThreatType.suspiciousLogin,
          severity: SecurityLevel.low,
          title: 'New Device Login',
          description: 'Login from new device detected',
          userId: userId,
          deviceId: deviceId,
          detectedAt: DateTime.now(),
          evidence: {'deviceId': deviceId},
          recommendedAction: SecurityAction.warn,
        ));
      }
      
      // Check for rapid login attempts
      final rapidLogins = await _getRapidLoginAttempts(userId);
      if (rapidLogins >= 3) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_3',
          type: ThreatType.bruteForce,
          severity: SecurityLevel.medium,
          title: 'Rapid Login Attempts',
          description: 'Detected $rapidLogins login attempts in short time period',
          userId: userId,
          detectedAt: DateTime.now(),
          evidence: {'rapidLogins': rapidLogins},
          recommendedAction: SecurityAction.requireVerification,
        ));
      }
      
    } catch (e) {
      cprint('Error detecting suspicious login: $e', errorIn: 'SecurityService');
    }
    
    return threats;
  }
  
  /// Analyze user behavior for anomalies
  Future<List<SecurityThreat>> analyzeUserBehavior(String userId) async {
    final threats = <SecurityThreat>[];
    
    try {
      // Check for unusual activity patterns
      final activityPattern = await _analyzeActivityPattern(userId);
      if (activityPattern['isUnusual'] == true) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: ThreatType.unusualActivity,
          severity: SecurityLevel.medium,
          title: 'Unusual Activity Pattern',
          description: 'Detected unusual user activity pattern',
          userId: userId,
          detectedAt: DateTime.now(),
          evidence: activityPattern,
          recommendedAction: SecurityAction.warn,
        ));
      }
      
      // Check for potential account takeover
      final takeoverIndicators = await _checkAccountTakeoverIndicators(userId);
      if (takeoverIndicators['riskScore'] > 0.7) {
        threats.add(SecurityThreat(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_1',
          type: ThreatType.accountTakeover,
          severity: SecurityLevel.critical,
          title: 'Potential Account Takeover',
          description: 'Multiple indicators suggest possible account takeover',
          userId: userId,
          detectedAt: DateTime.now(),
          evidence: takeoverIndicators,
          recommendedAction: SecurityAction.lockAccount,
        ));
      }
      
    } catch (e) {
      cprint('Error analyzing user behavior: $e', errorIn: 'SecurityService');
    }
    
    return threats;
  }
  
  /// Validate device fingerprint
  Future<bool> validateDeviceFingerprint({
    required String userId,
    required String deviceId,
    required String fingerprint,
  }) async {
    try {
      final snapshot = await _database
          .child('devices')
          .child(userId)
          .orderByChild('deviceId')
          .equalTo(deviceId)
          .get();
      
      if (snapshot.exists) {
        final devicesMap = snapshot.value as Map<String, dynamic>;
        for (final entry in devicesMap.entries) {
          final device = SecurityDevice.fromJson(entry.value);
          if (device.matchesFingerprint(fingerprint)) {
            return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      cprint('Error validating device fingerprint: $e', errorIn: 'SecurityService');
      return false;
    }
  }
  
  /// Check for compromised credentials
  Future<bool> checkCompromisedCredentials(String email, String passwordHash) async {
    try {
      // This would integrate with a breach detection service
      // For now, simulate basic checks
      
      final snapshot = await _database
          .child('compromisedCredentials')
          .orderByChild('email')
          .equalTo(email)
          .get();
      
      if (snapshot.exists) {
        final breaches = snapshot.value as Map<String, dynamic>;
        for (final entry in breaches.entries) {
          final breach = entry.value;
          if (breach['passwordHash'] == passwordHash) {
            return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      cprint('Error checking compromised credentials: $e', errorIn: 'SecurityService');
      return false;
    }
  }
  
  /// Generate security report
  Future<Map<String, dynamic>> generateSecurityReport(String userId) async {
    try {
      final report = <String, dynamic>{};
      
      // Get security events
      final eventsSnapshot = await _database
          .child('events')
          .child(userId)
          .limitToLast(100)
          .get();
      
      final events = <SecurityEvent>[];
      if (eventsSnapshot.exists) {
        final eventsMap = eventsSnapshot.value as Map<String, dynamic>;
        for (final entry in eventsMap.entries) {
          events.add(SecurityEvent.fromJson(entry.value));
        }
      }
      
      // Get active sessions
      final sessionsSnapshot = await _database
          .child('sessions')
          .child(userId)
          .get();
      
      final sessions = <SecuritySession>[];
      if (sessionsSnapshot.exists) {
        final sessionsMap = sessionsSnapshot.value as Map<String, dynamic>;
        for (final entry in sessionsMap.entries) {
          final session = SecuritySession.fromJson(entry.value);
          if (session.isActive) {
            sessions.add(session);
          }
        }
      }
      
      // Get threats
      final threatsSnapshot = await _database
          .child('threats')
          .child(userId)
          .get();
      
      final threats = <SecurityThreat>[];
      if (threatsSnapshot.exists) {
        final threatsMap = threatsSnapshot.value as Map<String, dynamic>;
        for (final entry in threatsMap.entries) {
          threats.add(SecurityThreat.fromJson(entry.value));
        }
      }
      
      // Calculate metrics
      report['totalEvents'] = events.length;
      report['criticalEvents'] = events.where((e) => e.isCritical).length;
      report['unresolvedEvents'] = events.where((e) => !e.isResolved).length;
      report['activeSessions'] = sessions.length;
      report['activeThreats'] = threats.where((t) => t.isActive).length;
      report['criticalThreats'] = threats.where((t) => t.isCritical).length;
      report['securityScore'] = _calculateSecurityScore(events, sessions, threats);
      report['recommendations'] = _generateSecurityRecommendations(events, sessions, threats);
      
      return report;
    } catch (e) {
      cprint('Error generating security report: $e', errorIn: 'SecurityService');
      return {};
    }
  }
  
  /// Send security alert
  Future<void> sendSecurityAlert({
    required String userId,
    required SecurityLevel severity,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final alert = {
        'userId': userId,
        'severity': severity.name,
        'title': title,
        'message': message,
        'data': data ?? {},
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
      };
      
      await _database
          .child('securityAlerts')
          .push()
          .set(alert);
      
      cprint('Security alert sent: $title', event: 'security_alert');
    } catch (e) {
      cprint('Error sending security alert: $e', errorIn: 'SecurityService');
    }
  }
  
  /// Lock user account
  Future<void> lockUserAccount({
    required String userId,
    required String reason,
    Duration? duration,
  }) async {
    try {
      final lockData = {
        'isLocked': true,
        'lockedAt': DateTime.now().toIso8601String(),
        'lockedReason': reason,
        'lockedUntil': duration != null 
            ? DateTime.now().add(duration).toIso8601String()
            : null,
      };
      
      await _database
          .child('users')
          .child(userId)
          .child('security')
          .update(lockData);
      
      // Create security event
      await _createSecurityEvent(
        userId: userId,
        eventType: SecurityEventType.accountLocked,
        severity: SecurityLevel.high,
        description: reason,
      );
      
      cprint('User account locked: $userId', event: 'account_locked');
    } catch (e) {
      cprint('Error locking user account: $e', errorIn: 'SecurityService');
    }
  }
  
  /// Unlock user account
  Future<void> unlockUserAccount({
    required String userId,
    required String unlockedBy,
  }) async {
    try {
      final lockData = {
        'isLocked': false,
        'unlockedAt': DateTime.now().toIso8601String(),
        'unlockedBy': unlockedBy,
      };
      
      await _database
          .child('users')
          .child(userId)
          .child('security')
          .update(lockData);
      
      // Create security event
      await _createSecurityEvent(
        userId: userId,
        eventType: SecurityEventType.accountUnlocked,
        severity: SecurityLevel.low,
        description: 'Account unlocked by $unlockedBy',
      );
      
      cprint('User account unlocked: $userId', event: 'account_unlocked');
    } catch (e) {
      cprint('Error unlocking user account: $e', errorIn: 'SecurityService');
    }
  }
  
  /// Cleanup old security data
  Future<void> cleanupOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      
      // Clean up old security events
      final eventsSnapshot = await _database
          .child('events')
          .get();
      
      if (eventsSnapshot.exists) {
        final events = eventsSnapshot.value as Map<String, dynamic>;
        for (final userId in events.keys) {
          final userEvents = events[userId] as Map<String, dynamic>;
          for (final eventId in userEvents.keys) {
            final event = userEvents[eventId];
            if (DateTime.parse(event['timestamp']).isBefore(cutoffDate)) {
              await _database
                  .child('events')
                  .child(userId)
                  .child(eventId)
                  .remove();
            }
          }
        }
      }
      
      // Clean up old sessions
      final sessionsSnapshot = await _database
          .child('sessions')
          .get();
      
      if (sessionsSnapshot.exists) {
        final sessions = sessionsSnapshot.value as Map<String, dynamic>;
        for (final userId in sessions.keys) {
          final userSessions = sessions[userId] as Map<String, dynamic>;
          for (final sessionId in userSessions.keys) {
            final session = userSessions[sessionId];
            if (DateTime.parse(session['expiresAt']).isBefore(cutoffDate)) {
              await _database
                  .child('sessions')
                  .child(userId)
                  .child(sessionId)
                  .remove();
            }
          }
        }
      }
      
      cprint('Old security data cleanup completed', event: 'security_cleanup');
    } catch (e) {
      cprint('Error cleaning up security data: $e', errorIn: 'SecurityService');
    }
  }
  
  /// Private helper methods
  
  Future<int> _getFailedLoginAttempts(String userId, String ipAddress) async {
    try {
      final snapshot = await _database
          .child('failedLogins')
          .child(userId)
          .orderByChild('ipAddress')
          .equalTo(ipAddress)
          .limitToLast(10)
          .get();
      
      if (snapshot.exists) {
        final attempts = snapshot.value as Map<String, dynamic>;
        return attempts.length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<bool> _isUnusualLocation(String userId, String ipAddress) async {
    try {
      // Get known locations for this user
      final snapshot = await _database
          .child('userLocations')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final locations = snapshot.value as Map<String, dynamic>;
        return !locations.containsKey(ipAddress);
      }
      
      return true; // No known locations, so this is unusual
    } catch (e) {
      return true;
    }
  }
  
  Future<bool> _isNewDevice(String userId, String deviceId) async {
    try {
      final snapshot = await _database
          .child('devices')
          .child(userId)
          .orderByChild('deviceId')
          .equalTo(deviceId)
          .get();
      
      return !snapshot.exists;
    } catch (e) {
      return true;
    }
  }
  
  Future<int> _getRapidLoginAttempts(String userId) async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(minutes: 5));
      
      final snapshot = await _database
          .child('events')
          .child(userId)
          .orderByChild('timestamp')
          .startAt(cutoffTime.millisecondsSinceEpoch)
          .get();
      
      if (snapshot.exists) {
        final events = snapshot.value as Map<String, dynamic>;
        return events.values.where((event) => 
          event['eventType'] == 'login'
        ).length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<Map<String, dynamic>> _analyzeActivityPattern(String userId) async {
    try {
      // This would analyze user activity patterns
      // For now, return dummy data
      return {
        'isUnusual': false,
        'confidence': 0.1,
        'pattern': 'normal',
      };
    } catch (e) {
      return {'isUnusual': false, 'confidence': 0.0};
    }
  }
  
  Future<Map<String, dynamic>> _checkAccountTakeoverIndicators(String userId) async {
    try {
      final indicators = <String, dynamic>{};
      double riskScore = 0.0;
      
      // Check for multiple new devices
      final newDevicesCount = await _getNewDevicesCount(userId, Duration(days: 7));
      if (newDevicesCount > 3) {
        indicators['newDevices'] = newDevicesCount;
        riskScore += 0.3;
      }
      
      // Check for password changes
      final passwordChanges = await _getPasswordChangesCount(userId, Duration(days: 7));
      if (passwordChanges > 1) {
        indicators['passwordChanges'] = passwordChanges;
        riskScore += 0.4;
      }
      
      // Check for email changes
      final emailChanges = await _getEmailChangesCount(userId, Duration(days: 30));
      if (emailChanges > 0) {
        indicators['emailChanges'] = emailChanges;
        riskScore += 0.3;
      }
      
      indicators['riskScore'] = riskScore;
      return indicators;
    } catch (e) {
      return {'riskScore': 0.0};
    }
  }
  
  Future<int> _getNewDevicesCount(String userId, Duration period) async {
    try {
      final cutoffTime = DateTime.now().subtract(period);
      
      final snapshot = await _database
          .child('devices')
          .child(userId)
          .orderByChild('firstSeen')
          .startAt(cutoffTime.millisecondsSinceEpoch)
          .get();
      
      if (snapshot.exists) {
        final devices = snapshot.value as Map<String, dynamic>;
        return devices.length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _getPasswordChangesCount(String userId, Duration period) async {
    try {
      final cutoffTime = DateTime.now().subtract(period);
      
      final snapshot = await _database
          .child('events')
          .child(userId)
          .orderByChild('timestamp')
          .startAt(cutoffTime.millisecondsSinceEpoch)
          .get();
      
      if (snapshot.exists) {
        final events = snapshot.value as Map<String, dynamic>;
        return events.values.where((event) => 
          event['eventType'] == 'passwordChange'
        ).length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  Future<int> _getEmailChangesCount(String userId, Duration period) async {
    try {
      final cutoffTime = DateTime.now().subtract(period);
      
      final snapshot = await _database
          .child('events')
          .child(userId)
          .orderByChild('timestamp')
          .startAt(cutoffTime.millisecondsSinceEpoch)
          .get();
      
      if (snapshot.exists) {
        final events = snapshot.value as Map<String, dynamic>;
        return events.values.where((event) => 
          event['eventType'] == 'emailChange'
        ).length;
      }
      
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  double _calculateSecurityScore(List<SecurityEvent> events, List<SecuritySession> sessions, List<SecurityThreat> threats) {
    double score = 100.0;
    
    // Deduct for critical events
    score -= events.where((e) => e.isCritical).length * 10;
    
    // Deduct for unresolved events
    score -= events.where((e) => !e.isResolved).length * 5;
    
    // Deduct for active threats
    score -= threats.where((t) => t.isActive).length * 15;
    
    // Deduct for critical threats
    score -= threats.where((t) => t.isCritical).length * 25;
    
    // Deduct for too many active sessions
    if (sessions.length > 5) {
      score -= (sessions.length - 5) * 5;
    }
    
    return score.clamp(0.0, 100.0);
  }
  
  List<String> _generateSecurityRecommendations(List<SecurityEvent> events, List<SecuritySession> sessions, List<SecurityThreat> threats) {
    final recommendations = <String>[];
    
    if (events.where((e) => !e.isResolved).length > 5) {
      recommendations.add('Review and resolve unresolved security events');
    }
    
    if (sessions.length > 5) {
      recommendations.add('Consider limiting active sessions for better security');
    }
    
    if (threats.where((t) => t.isActive).length > 0) {
      recommendations.add('Address active security threats immediately');
    }
    
    if (events.where((e) => e.eventType == SecurityEventType.login).length > 20) {
      recommendations.add('Monitor login patterns for unusual activity');
    }
    
    return recommendations;
  }
  
  Future<void> _createSecurityEvent({
    required String userId,
    required SecurityEventType eventType,
    required SecurityLevel severity,
    required String description,
  }) async {
    try {
      final event = {
        'userId': userId,
        'eventType': eventType.name,
        'severity': severity.name,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
        'isResolved': false,
      };
      
      await _database
          .child('events')
          .child(userId)
          .push()
          .set(event);
    } catch (e) {
      cprint('Error creating security event: $e', errorIn: 'SecurityService');
    }
  }
}
