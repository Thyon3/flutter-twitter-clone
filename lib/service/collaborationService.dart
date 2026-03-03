import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/collaborationModel.dart';
import 'package:twitterclone/model/collaborationDocumentModel.dart';
import 'package:twitterclone/model/realtimePresenceModel.dart';
import 'package:twitterclone/helper/utility.dart';

class CollaborationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Map<String, StreamSubscription> _subscriptions = {};
  
  CollaborationService();
  
  /// Start real-time collaboration
  StreamSubscription<DocumentChange> listenToDocumentChanges(String documentId) {
    if (_subscriptions.containsKey(documentId)) {
      return _subscriptions[documentId]!;
    }
    
    final subscription = _database
        .child('documents')
        .child(documentId)
        .child('changeHistory')
        .onChildAdded
        .listen((event) {
      if (event.snapshot.exists) {
        final change = DocumentChange.fromJson(event.snapshot.value as Map<String, dynamic>);
        cprint('Document change detected: ${change.changeType}', event: 'document_change');
      }
    });
    
    _subscriptions[documentId] = subscription;
    return subscription;
  }
  
  /// Start real-time presence tracking
  StreamSubscription<DatabaseEvent> listenToPresence(String userId) {
    return _database
        .child('presence')
        .child(userId)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final presence = RealtimePresence.fromJson(event.snapshot.value as Map<String, dynamic>);
        cprint('Presence update: ${presence.status}', event: 'presence_update');
      }
    });
  }
  
  /// Listen to project members
  StreamSubscription<DatabaseEvent> listenToProjectMembers(String projectId) {
    return _database
        .child('projects')
        .child(projectId)
        .child('members')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final membersMap = event.snapshot.value as Map<String, dynamic>;
        cprint('Project members updated: ${membersMap.length} members', event: 'project_members');
      }
    });
  }
  
  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String documentId,
    required bool isTyping,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final presenceEvent = PresenceEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        eventType: isTyping ? PresenceEventType.typing : PresenceEventType.stoppedTyping,
        eventData: {'documentId': documentId},
        timestamp: DateTime.now(),
        source: 'document',
      );
      
      await _database
          .child('presenceEvents')
          .push()
          .set(presenceEvent.toJson());
      
      cprint('Typing indicator sent: $isTyping', event: 'typing_indicator');
    } catch (e) {
      cprint('Error sending typing indicator: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Lock document for editing
  Future<bool> lockDocument({
    required String documentId,
    required String reason,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return false;
      
      // Check if document is already locked
      final lockSnapshot = await _database
          .child('documents')
          .child(documentId)
          .child('locks')
          .limitToLast(1)
          .get();
      
      if (lockSnapshot.exists) {
        final locks = lockSnapshot.value as Map<String, dynamic>;
        for (final lockEntry in locks.entries) {
          final lock = DocumentLock.fromJson(lockEntry.value);
          if (!lock.isExpired && lock.userId != userId) {
            return false; // Document is locked by someone else
          }
        }
      }
      
      // Create new lock
      final lock = DocumentLock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: documentId,
        userId: userId,
        reason: reason,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );
      
      await _database
          .child('documents')
          .child(documentId)
          .child('locks')
          .push()
          .set(lock.toJson());
      
      cprint('Document locked: $documentId', event: 'document_lock');
      return true;
    } catch (e) {
      cprint('Error locking document: $e', errorIn: 'CollaborationService');
      return false;
    }
  }
  
  /// Unlock document
  Future<void> unlockDocument({
    required String documentId,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Remove locks by this user
      final lockSnapshot = await _database
          .child('documents')
          .child(documentId)
          .child('locks')
          .get();
      
      if (lockSnapshot.exists) {
        final locks = lockSnapshot.value as Map<String, dynamic>;
        for (final lockEntry in locks.entries) {
          final lock = DocumentLock.fromJson(lockEntry.value);
          if (lock.userId == userId) {
            await _database
                .child('documents')
                .child(documentId)
                .child('locks')
                .child(lockEntry.key)
                .remove();
          }
        }
      }
      
      cprint('Document unlocked: $documentId', event: 'document_unlock');
    } catch (e) {
      cprint('Error unlocking document: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Add comment to document
  Future<void> addComment({
    required String documentId,
    required String content,
    String? parentId,
    List<String> mentions = const [],
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final comment = DocumentComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        documentId: documentId,
        authorId: userId,
        content: content,
        createdAt: DateTime.now(),
        parentId: parentId,
        mentions: mentions,
        isResolved: false,
      );
      
      await _database
          .child('documents')
          .child(documentId)
          .child('comments')
          .push()
          .set(comment.toJson());
      
      // Update document statistics
      await _updateDocumentStatistics(documentId, 'comments', 1);
      
      cprint('Comment added: $documentId', event: 'add_comment');
    } catch (e) {
      cprint('Error adding comment: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Create document version
  Future<void> createVersion({
    required String documentId,
    required String content,
    String? changeDescription,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Get current version number
      final versionSnapshot = await _database
          .child('documents')
          .child(documentId)
          .child('versions')
          .orderByChild('versionNumber')
          .limitToLast(1)
          .get();
      
      int currentVersion = 0;
      if (versionSnapshot.exists) {
        final versions = versionSnapshot.value as Map<String, dynamic>;
        for (final versionEntry in versions.entries) {
          final version = DocumentVersion.fromJson(versionEntry.value);
          currentVersion = version.versionNumber;
        }
      }
      
      final newVersion = DocumentVersion(
        id: '${documentId}_v${currentVersion + 1}',
        documentId: documentId,
        versionNumber: currentVersion + 1,
        content: content,
        authorId: userId,
        changeDescription: changeDescription,
        createdAt: DateTime.now(),
      );
      
      await _database
          .child('documents')
          .child(documentId)
          .child('versions')
          .push()
          .set(newVersion.toJson());
      
      // Update document statistics
      await _updateDocumentStatistics(documentId, 'edits', 1);
      
      cprint('Version created: $documentId', event: 'create_version');
    } catch (e) {
      cprint('Error creating version: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Invite member to project
  Future<void> inviteMember({
    required String projectId,
    required String userId,
    required CollaborationRole role,
    String? message,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;
      
      final invitation = {
        'projectId': projectId,
        'inviterId': currentUserId,
        'inviteeId': userId,
        'role': role.name,
        'message': message,
        'status': CollaborationStatus.pending.name,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      await _database
          .child('invitations')
          .push()
          .set(invitation);
      
      cprint('Member invited: $userId to $projectId', event: 'invite_member');
    } catch (e) {
      cprint('Error inviting member: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Update member role
  Future<void> updateMemberRole({
    required String projectId,
    required String userId,
    required CollaborationRole newRole,
  }) async {
    try {
      await _database
          .child('projects')
          .child(projectId)
          .child('members')
          .child(userId)
          .update({'role': newRole.name});
      
      cprint('Member role updated: $userId to $newRole', event: 'update_role');
    } catch (e) {
      cprint('Error updating member role: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Share document
  Future<void> shareDocument({
    required String documentId,
    required List<String> userIds,
    required CollaborationPermission permission,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;
      
      for (final userId in userIds) {
        final share = {
          'documentId': documentId,
          'sharedById': currentUserId,
          'sharedWithId': userId,
          'permission': permission.name,
          'sharedAt': DateTime.now().toIso8601String(),
        };
        
        await _database
            .child('documentShares')
            .push()
            .set(share);
      }
      
      // Update document statistics
      await _updateDocumentStatistics(documentId, 'shares', userIds.length);
      
      cprint('Document shared: $documentId with ${userIds.length} users', event: 'share_document');
    } catch (e) {
      cprint('Error sharing document: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Auto-save document
  Future<void> autoSaveDocument({
    required String documentId,
    required String content,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final autoSave = {
        'documentId': documentId,
        'userId': userId,
        'content': content,
        'savedAt': DateTime.now().toIso8601String(),
        'isAutoSave': true,
      };
      
      await _database
          .child('autoSaves')
          .child(documentId)
          .child(userId)
          .set(autoSave);
      
      cprint('Document auto-saved: $documentId', event: 'auto_save');
    } catch (e) {
      cprint('Error auto-saving document: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Get active users in document
  Future<List<RealtimePresence>> getActiveUsersInDocument(String documentId) async {
    try {
      final snapshot = await _database
          .child('presence')
          .orderByChild('documentId')
          .equalTo(documentId)
          .get();
      
      if (snapshot.exists) {
        final presenceMap = snapshot.value as Map<String, dynamic>;
        final activeUsers = <RealtimePresence>[];
        
        for (final entry in presenceMap.entries) {
          final presence = RealtimePresence.fromJson(entry.value);
          if (presence.isOnline && presence.documentId == documentId) {
            activeUsers.add(presence);
          }
        }
        
        return activeUsers;
      }
      
      return [];
    } catch (e) {
      cprint('Error getting active users: $e', errorIn: 'CollaborationService');
      return [];
    }
  }
  
  /// Resolve merge conflicts
  Future<void> resolveConflict({
    required String documentId,
    required String resolvedContent,
    required List<String> conflictingVersionIds,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final resolution = {
        'documentId': documentId,
        'resolvedById': userId,
        'resolvedContent': resolvedContent,
        'conflictingVersionIds': conflictingVersionIds,
        'resolvedAt': DateTime.now().toIso8601String(),
      };
      
      await _database
          .child('conflictResolutions')
          .push()
          .set(resolution);
      
      // Update document with resolved content
      await _database
          .child('documents')
          .child(documentId)
          .update({
            'content': resolvedContent,
            'lastEdited': DateTime.now().toIso8601String(),
            'lastEditedBy': userId,
          });
      
      cprint('Conflict resolved: $documentId', event: 'resolve_conflict');
    } catch (e) {
      cprint('Error resolving conflict: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Cleanup old data
  Future<void> cleanupOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      // Clean up old presence events
      final presenceEventsSnapshot = await _database
          .child('presenceEvents')
          .orderByChild('timestamp')
          .endAt(cutoffDate.millisecondsSinceEpoch)
          .get();
      
      if (presenceEventsSnapshot.exists) {
        final events = presenceEventsSnapshot.value as Map<String, dynamic>;
        for (final entry in events.entries) {
          await _database
              .child('presenceEvents')
              .child(entry.key)
              .remove();
        }
      }
      
      // Clean up old auto-saves
      final autoSavesSnapshot = await _database
          .child('autoSaves')
          .orderByChild('savedAt')
          .endAt(cutoffDate.millisecondsSinceEpoch)
          .get();
      
      if (autoSavesSnapshot.exists) {
        final saves = autoSavesSnapshot.value as Map<String, dynamic>;
        for (final entry in saves.entries) {
          await _database
              .child('autoSaves')
              .child(entry.key)
              .remove();
        }
      }
      
      cprint('Old data cleanup completed', event: 'cleanup_data');
    } catch (e) {
      cprint('Error cleaning up data: $e', errorIn: 'CollaborationService');
    }
  }
  
  /// Dispose all subscriptions
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
  
  /// Private helper methods
  
  Future<void> _updateDocumentStatistics(String documentId, String field, int increment) async {
    try {
      await _database
          .child('documents')
          .child(documentId)
          .child('statistics')
          .child(field)
          .set(ServerValue.increment(increment));
    } catch (e) {
      cprint('Error updating statistics: $e', errorIn: 'CollaborationService');
    }
  }
}
