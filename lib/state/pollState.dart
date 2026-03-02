import 'package:firebase_database/firebase_database.dart';
import 'package:twitterclone/model/pollModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/base/tweetBaseState.dart';

class PollState extends TweetBaseState {
  final DatabaseReference _pollReference = FirebaseDatabase.instance.ref();
  
  List<PollModel> _userPolls = [];
  List<PollModel> _feedPolls = [];
  bool _isLoading = false;
  bool _isCreatingPoll = false;
  
  // Getters
  List<PollModel> get userPolls => _userPolls;
  List<PollModel> get feedPolls => _feedPolls;
  bool get isLoading => _isLoading;
  bool get isCreatingPoll => _isCreatingPoll;
  
  /// Create a new poll
  Future<String?> createPoll({
    required String question,
    required List<String> optionTexts,
    Duration? duration,
    bool isMultipleChoice = false,
  }) async {
    try {
      _isCreatingPoll = true;
      notifyListeners();
      
      final authState = AuthState();
      final currentUser = authState.userModel;
      
      if (currentUser == null) {
        return null;
      }
      
      // Validate poll data
      if (question.trim().isEmpty || optionTexts.length < 2 || optionTexts.length > 4) {
        return null;
      }
      
      // Create poll options
      final options = optionTexts.map((text) {
        return PollOption(
          id: _pollReference.child('polls').push().key ?? DateTime.now().millisecondsSinceEpoch.toString(),
          text: text.trim(),
        );
      }).toList();
      
      // Set expiration time (default: 24 hours)
      final expiresAt = DateTime.now().add(duration ?? const Duration(days: 1));
      
      // Create poll
      final pollId = _pollReference.child('polls').push().key;
      final poll = PollModel(
        id: pollId,
        question: question.trim(),
        options: options,
        userId: currentUser.userId,
        createdAt: DateTime.now().toIso8601String(),
        expiresAt: expiresAt.toIso8601String(),
        isMultipleChoice: isMultipleChoice,
        isActive: true,
        totalVotes: 0,
        user: currentUser,
      );
      
      // Validate poll before saving
      if (!poll.isValidPoll) {
        return null;
      }
      
      // Save to database
      await _pollReference
          .child('polls')
          .child(pollId!)
          .set(poll.toJson());
      
      // Add to local lists
      _userPolls.insert(0, poll);
      _feedPolls.insert(0, poll);
      
      _isCreatingPoll = false;
      notifyListeners();
      
      return pollId;
    } catch (e) {
      print('Error creating poll: $e');
      _isCreatingPoll = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Load user's polls
  Future<void> loadUserPolls(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _pollReference
          .child('polls')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> pollsData = snapshot.value as Map;
        List<PollModel> polls = [];
        
        for (var entry in pollsData.entries) {
          final pollData = Map<String, dynamic>.from(entry.value);
          pollData['id'] = entry.key.toString();
          
          final poll = PollModel.fromJson(pollData);
          if (poll.isValidPoll) {
            polls.add(poll);
          }
        }
        
        // Sort by creation time (newest first)
        polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _userPolls = polls;
      }
    } catch (e) {
      print('Error loading user polls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load polls for feed
  Future<void> loadFeedPolls({int limit = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _pollReference
          .child('polls')
          .orderByChild('createdAt')
          .limitToFirst(limit)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> pollsData = snapshot.value as Map;
        List<PollModel> polls = [];
        
        for (var entry in pollsData.entries) {
          final pollData = Map<String, dynamic>.from(entry.value);
          pollData['id'] = entry.key.toString();
          
          final poll = PollModel.fromJson(pollData);
          if (poll.isValidPoll) {
            polls.add(poll);
          }
        }
        
        // Sort by creation time (newest first)
        polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _feedPolls = polls;
      }
    } catch (e) {
      print('Error loading feed polls: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Vote in a poll
  Future<bool> voteInPoll(String pollId, String userId, List<String> optionIds) async {
    try {
      // Find the poll in local lists
      PollModel? poll;
      int? userIndex;
      int? feedIndex;
      
      for (int i = 0; i < _userPolls.length; i++) {
        if (_userPolls[i].id == pollId) {
          poll = _userPolls[i];
          userIndex = i;
          break;
        }
      }
      
      if (poll == null) {
        for (int i = 0; i < _feedPolls.length; i++) {
          if (_feedPolls[i].id == pollId) {
            poll = _feedPolls[i];
            feedIndex = i;
            break;
          }
        }
      }
      
      if (poll == null) {
        return false;
      }
      
      // Check if user can vote
      if (!poll.canUserVote(userId)) {
        return false;
      }
      
      // Vote in the poll
      final success = poll.vote(userId, optionIds);
      
      if (!success) {
        return false;
      }
      
      // Update in database
      await _pollReference
          .child('polls')
          .child(pollId)
          .update({
            'options': poll.options.map((option) => option.toJson()).toList(),
            'totalVotes': poll.totalVotes,
          });
      
      // Update local lists
      if (userIndex != null) {
        _userPolls[userIndex] = poll;
      }
      if (feedIndex != null) {
        _feedPolls[feedIndex] = poll;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error voting in poll: $e');
      return false;
    }
  }
  
  /// Remove vote from a poll
  Future<bool> removeVoteFromPoll(String pollId, String userId) async {
    try {
      // Find the poll in local lists
      PollModel? poll;
      int? userIndex;
      int? feedIndex;
      
      for (int i = 0; i < _userPolls.length; i++) {
        if (_userPolls[i].id == pollId) {
          poll = _userPolls[i];
          userIndex = i;
          break;
        }
      }
      
      if (poll == null) {
        for (int i = 0; i < _feedPolls.length; i++) {
          if (_feedPolls[i].id == pollId) {
            poll = _feedPolls[i];
            feedIndex = i;
            break;
          }
        }
      }
      
      if (poll == null) {
        return false;
      }
      
      // Remove vote from the poll
      final success = poll.removeVote(userId);
      
      if (!success) {
        return false;
      }
      
      // Update in database
      await _pollReference
          .child('polls')
          .child(pollId)
          .update({
            'options': poll.options.map((option) => option.toJson()).toList(),
            'totalVotes': poll.totalVotes,
          });
      
      // Update local lists
      if (userIndex != null) {
        _userPolls[userIndex] = poll;
      }
      if (feedIndex != null) {
        _feedPolls[feedIndex] = poll;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error removing vote from poll: $e');
      return false;
    }
  }
  
  /// Delete a poll
  Future<bool> deletePoll(String pollId) async {
    try {
      final authState = AuthState();
      final currentUserId = authState.userModel?.userId;
      
      if (currentUserId == null) {
        return false;
      }
      
      // Find the poll
      PollModel? poll;
      int? userIndex;
      int? feedIndex;
      
      for (int i = 0; i < _userPolls.length; i++) {
        if (_userPolls[i].id == pollId) {
          poll = _userPolls[i];
          userIndex = i;
          break;
        }
      }
      
      if (poll == null || poll.userId != currentUserId) {
        return false;
      }
      
      // Delete from database
      await _pollReference
          .child('polls')
          .child(pollId)
          .remove();
      
      // Remove from local lists
      if (userIndex != null) {
        _userPolls.removeAt(userIndex);
      }
      for (int i = 0; i < _feedPolls.length; i++) {
        if (_feedPolls[i].id == pollId) {
          feedIndex = i;
          break;
        }
      }
      if (feedIndex != null) {
        _feedPolls.removeAt(feedIndex);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting poll: $e');
      return false;
    }
  }
  
  /// Get poll by ID
  PollModel? getPollById(String pollId) {
    try {
      for (var poll in _userPolls) {
        if (poll.id == pollId) {
          return poll;
        }
      }
      for (var poll in _feedPolls) {
        if (poll.id == pollId) {
          return poll;
        }
      }
      return null;
    } catch (e) {
      print('Error getting poll by ID: $e');
      return null;
    }
  }
  
  /// Clear all polls
  void clearAll() {
    _userPolls.clear();
    _feedPolls.clear();
    notifyListeners();
  }
  
  /// Refresh poll data
  Future<void> refreshPolls() async {
    final authState = AuthState();
    final userId = authState.userModel?.userId;
    
    if (userId != null) {
      await Future.wait([
        loadUserPolls(userId),
        loadFeedPolls(),
      ]);
    }
  }
  
  /// Get active polls only
  List<PollModel> get activePolls {
    return _feedPolls.where((poll) => poll.isActive && !poll.isExpired).toList();
  }
  
  /// Get expired polls only
  List<PollModel> get expiredPolls {
    return _feedPolls.where((poll) => poll.isExpired).toList();
  }
}
