import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/model/collaborationModel.dart';
import 'package:twitterclone/model/collaborationProjectModel.dart';
import 'package:twitterclone/model/collaborationDocumentModel.dart';
import 'package:twitterclone/model/realtimePresenceModel.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/state/appState.dart';

class CollaborationState extends AppState {
  final DatabaseReference _collaborationReference = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  
  // Projects and documents
  List<CollaborationProject> _projects = [];
  List<CollaborationDocument> _documents = [];
  CollaborationProject? _currentProject;
  CollaborationDocument? _currentDocument;
  
  // Members and presence
  List<CollaborationMember> _members = [];
  Map<String, RealtimePresence> _presence = {};
  List<PresenceEvent> _presenceEvents = [];
  
  // Real-time data
  Map<String, List<DocumentChange>> _documentChanges = {};
  Map<String, List<DocumentComment>> _documentComments = {};
  Map<String, List<DocumentLock>> _documentLocks = {};
  
  // Settings
  bool _autoSaveEnabled = true;
  Duration _autoSaveInterval = const Duration(minutes: 5);
  bool _realTimeEnabled = true;
  bool _notificationsEnabled = true;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  List<CollaborationProject> get projects => List.from(_projects);
  List<CollaborationDocument> get documents => List.from(_documents);
  CollaborationProject? get currentProject => _currentProject;
  CollaborationDocument? get currentDocument => _currentDocument;
  List<CollaborationMember> get members => List.from(_members);
  Map<String, RealtimePresence> get presence => Map.from(_presence);
  List<PresenceEvent> get presenceEvents => List.from(_presenceEvents);
  bool get autoSaveEnabled => _autoSaveEnabled;
  Duration get autoSaveInterval => _autoSaveInterval;
  bool get realTimeEnabled => _realTimeEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  
  // Computed properties
  List<CollaborationProject> get myProjects {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    return _projects.where((p) => p.members.any((m) => m.userId == userId)).toList();
  }
  
  List<CollaborationMember> get onlineMembers => _members.where((m) => m.isOnline).toList();
  
  List<CollaborationDocument> get activeDocuments => _documents.where((d) => !d.isArchived).toList();
  
  List<CollaborationMember> get projectMembers {
    if (_currentProject == null) return [];
    return _currentProject!.members;
  }
  
  /// Initialize collaboration state
  Future<void> initialize() async {
    await Future.wait([
      loadProjects(),
      loadDocuments(),
      loadMembers(),
      setupRealtimeListeners(),
    ]);
  }
  
  /// Load all projects
  Future<void> loadProjects() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _collaborationReference
          .child('projects')
          .orderByChild('members/$userId')
          .get();
      
      if (snapshot.exists) {
        final projectsMap = snapshot.value as Map<String, dynamic>;
        _projects = [];
        
        for (final entry in projectsMap.entries) {
          final project = CollaborationProject.fromJson(entry.value);
          _projects.add(project);
        }
        
        // Sort by last activity
        _projects.sort((a, b) => (b.lastActivity ?? b.updatedAt).compareTo(a.lastActivity ?? a.updatedAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load projects: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load all documents
  Future<void> loadDocuments() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _collaborationReference
          .child('documents')
          .orderByChild('coAuthors')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final documentsMap = snapshot.value as Map<String, dynamic>;
        _documents = [];
        
        for (final entry in documentsMap.entries) {
          final document = CollaborationDocument.fromJson(entry.value);
          _documents.add(document);
        }
        
        // Sort by last edited
        _documents.sort((a, b) => (b.lastEdited ?? b.updatedAt).compareTo(a.lastEdited ?? a.updatedAt));
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load documents: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load project members
  Future<void> loadMembers() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final snapshot = await _collaborationReference
          .child('members')
          .child(userId)
          .get();
      
      if (snapshot.exists) {
        final membersMap = snapshot.value as Map<String, dynamic>;
        _members = [];
        
        for (final entry in membersMap.entries) {
          final member = CollaborationMember.fromJson(entry.value);
          _members.add(member);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load members: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Setup real-time listeners
  Future<void> setupRealtimeListeners() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Listen for presence updates
      _collaborationReference
          .child('presence')
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          final presenceMap = event.snapshot.value as Map<String, dynamic>;
          _presence.clear();
          
          for (final entry in presenceMap.entries) {
            final presence = RealtimePresence.fromJson(entry.value);
            _presence[entry.key] = presence;
          }
          
          notifyListeners();
        }
      });
      
      // Listen for presence events
      _collaborationReference
          .child('presenceEvents')
          .limitToLast(50)
          .onChildAdded
          .listen((event) {
        if (event.snapshot.exists) {
          final presenceEvent = PresenceEvent.fromJson(event.snapshot.value as Map<String, dynamic>);
          _presenceEvents.insert(0, presenceEvent);
          
          // Keep only last 50 events
          if (_presenceEvents.length > 50) {
            _presenceEvents = _presenceEvents.take(50).toList();
          }
          
          notifyListeners();
        }
      });
      
      cprint('Real-time listeners setup', event: 'collaboration_listeners');
    } catch (e) {
      _error = 'Failed to setup real-time listeners: $e';
      notifyListeners();
    }
  }
  
  /// Create a new project
  Future<void> createProject({
    required String name,
    required String description,
    bool isPublic = false,
    List<String> tags = const [],
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final projectId = _collaborationReference.child('projects').push().key!;
      
      final project = CollaborationProject(
        id: projectId,
        name: name,
        description: description,
        ownerId: userId,
        members: [],
        documents: [],
        settings: ProjectSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        isActive: true,
        isPublic: isPublic,
        tags: tags,
        metadata: {},
        statistics: ProjectStatistics(
          totalDocuments: 0,
          totalMembers: 1,
          activeMembers: 1,
          totalComments: 0,
          totalEdits: 0,
          totalViews: 0,
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
        ),
      );
      
      // Save to Firebase
      await _collaborationReference
          .child('projects')
          .child(projectId)
          .set(project.toJson());
      
      // Add to local list
      _projects.insert(0, project);
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Project created: $projectId', event: 'create_project');
    } catch (e) {
      _error = 'Failed to create project: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Create a new document
  Future<void> createDocument({
    required String projectId,
    required String title,
    required String content,
    ContentType type = ContentType.draft,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final documentId = _collaborationReference.child('documents').push().key!;
      
      final document = CollaborationDocument(
        id: documentId,
        projectId: projectId,
        title: title,
        content: content,
        type: type,
        authorId: userId,
        coAuthors: [],
        versions: [
          DocumentVersion(
            id: '${documentId}_v1',
            documentId: documentId,
            versionNumber: 1,
            content: content,
            authorId: userId,
            createdAt: DateTime.now(),
          ),
        ],
        comments: [],
        locks: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastEdited: DateTime.now(),
        lastEditedBy: userId,
        isPublished: false,
        isArchived: false,
        isLocked: false,
        metadata: {},
        tags: [],
        statistics: DocumentStatistics(
          views: 0,
          edits: 1,
          comments: 0,
          shares: 0,
          downloads: 0,
          uniqueViewers: 0,
          firstView: DateTime.now(),
          lastView: DateTime.now(),
          viewsByDate: {},
        ),
        changeHistory: [
          DocumentChange(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            documentId: documentId,
            userId: userId,
            changeType: ChangeType.create,
            newValue: content,
            description: 'Document created',
            timestamp: DateTime.now(),
          ),
        ],
      );
      
      // Save to Firebase
      await _collaborationReference
          .child('documents')
          .child(documentId)
          .set(document.toJson());
      
      // Add to local list
      _documents.insert(0, document);
      
      _isProcessing = false;
      notifyListeners();
      
      cprint('Document created: $documentId', event: 'create_document');
    } catch (e) {
      _error = 'Failed to create document: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }
  
  /// Update presence
  Future<void> updatePresence({
    required PresenceStatus status,
    String? documentId,
    String? projectId,
    String? statusMessage,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final presence = RealtimePresence(
        userId: userId,
        documentId: documentId,
        projectId: projectId,
        status: status,
        statusMessage: statusMessage,
        lastSeen: DateTime.now(),
      );
      
      await _collaborationReference
          .child('presence')
          .child(userId)
          .set(presence.toJson());
      
      // Update local presence
      _presence[userId] = presence;
      notifyListeners();
      
      cprint('Presence updated: $status', event: 'update_presence');
    } catch (e) {
      _error = 'Failed to update presence: $e';
      notifyListeners();
    }
  }
  
  /// Set current project
  void setCurrentProject(CollaborationProject? project) {
    _currentProject = project;
    notifyListeners();
  }
  
  /// Set current document
  void setCurrentDocument(CollaborationDocument? document) {
    _currentDocument = document;
    notifyListeners();
  }
  
  /// Toggle auto-save
  void toggleAutoSave() {
    _autoSaveEnabled = !_autoSaveEnabled;
    notifyListeners();
  }
  
  /// Toggle real-time
  void toggleRealTime() {
    _realTimeEnabled = !_realTimeEnabled;
    notifyListeners();
  }
  
  /// Toggle notifications
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
  
  /// Get projects by tag
  List<CollaborationProject> getProjectsByTag(String tag) {
    return _projects.where((p) => p.tags.contains(tag)).toList();
  }
  
  /// Search projects
  List<CollaborationProject> searchProjects(String query) {
    if (query.isEmpty) return _projects;
    
    final lowerQuery = query.toLowerCase();
    return _projects.where((p) =>
      p.name.toLowerCase().contains(lowerQuery) ||
      p.description.toLowerCase().contains(lowerQuery) ||
      p.tags.any((t) => t.toLowerCase().contains(lowerQuery))
    ).toList();
  }
  
  /// Search documents
  List<CollaborationDocument> searchDocuments(String query) {
    if (query.isEmpty) return _documents;
    
    final lowerQuery = query.toLowerCase();
    return _documents.where((d) =>
      d.title.toLowerCase().contains(lowerQuery) ||
      d.content.toLowerCase().contains(lowerQuery) ||
      d.tags.any((t) => t.toLowerCase().contains(lowerQuery))
    ).toList();
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadProjects(),
      loadDocuments(),
      loadMembers(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
