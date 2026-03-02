import 'package:firebase_database/firebase_database.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/base/tweetBaseState.dart';

class ThreadState extends TweetBaseState {
  final DatabaseReference _threadReference = FirebaseDatabase.instance.ref();
  
  List<FeedModel> _currentThread = [];
  FeedModel? _threadStarter;
  bool _isLoadingThread = false;
  String? _currentThreadId;
  
  // Getters
  List<FeedModel> get currentThread => _currentThread;
  FeedModel? get threadStarter => _threadStarter;
  bool get isLoadingThread => _isLoadingThread;
  String? get currentThreadId => _currentThreadId;
  
  /// Get current user from AuthState
  UserModel get getCurrentUser {
    final authState = AuthState();
    return authState.userModel ?? UserModel();
  }
  
  /// Load a complete thread by thread ID
  Future<void> loadThread(String threadId) async {
    _isLoadingThread = true;
    _currentThreadId = threadId;
    notifyListeners();
    
    try {
      final snapshot = await _threadReference
          .child('tweets')
          .orderByChild('threadId')
          .equalTo(threadId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> tweetsData = snapshot.value as Map;
        List<FeedModel> threadTweets = [];
        
        // Sort tweets by thread position
        List<MapEntry<dynamic, dynamic>> sortedEntries = tweetsData.entries.toList()
          ..sort((a, b) {
            int posA = a.value['threadPosition'] ?? 0;
            int posB = b.value['threadPosition'] ?? 0;
            return posA.compareTo(posB);
          });
        
        for (var entry in sortedEntries) {
          final tweetData = Map<String, dynamic>.from(entry.value);
          tweetData['key'] = entry.key.toString();
          
          final tweet = FeedModel.fromJson(tweetData);
          if (tweet.isValidTweet) {
            threadTweets.add(tweet);
            
            // Identify thread starter
            if (tweet.isThreadStarter) {
              _threadStarter = tweet;
            }
          }
        }
        
        _currentThread = threadTweets;
      }
    } catch (e) {
      print('Error loading thread: $e');
    } finally {
      _isLoadingThread = false;
      notifyListeners();
    }
  }
  
  /// Create a new thread with the first tweet
  Future<String> createThread(FeedModel firstTweet) async {
    try {
      final threadId = _threadReference.child('threads').push().key;
      final tweetKey = _threadReference.child('tweets').push().key;
      
      // Update tweet with thread information
      firstTweet.key = tweetKey;
      firstTweet.threadId = threadId;
      firstTweet.threadPosition = 0;
      firstTweet.threadTotalCount = 1;
      firstTweet.isThreadStart = true;
      firstTweet.isThreadEnd = true;
      firstTweet.threadAuthorId = firstTweet.userId;
      
      // Save to database
      await _threadReference
          .child('tweets')
          .child(tweetKey!)
          .set(firstTweet.toJson());
      
      // Update thread metadata
      await _threadReference.child('threads').child(threadId!).set({
        'threadId': threadId,
        'authorId': firstTweet.userId,
        'createdAt': firstTweet.createdAt,
        'tweetCount': 1,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      _currentThreadId = threadId;
      return threadId;
    } catch (e) {
      print('Error creating thread: $e');
      rethrow;
    }
  }
  
  /// Add a tweet to an existing thread
  Future<bool> addToThread(String threadId, FeedModel newTweet) async {
    try {
      // Load current thread to determine position
      await loadThread(threadId);
      
      if (_currentThread.isEmpty) {
        return false;
      }
      
      final threadStarter = _threadStarter ?? _currentThread.first;
      final tweetKey = _threadReference.child('tweets').push().key;
      
      // Update new tweet with thread information
      newTweet.key = tweetKey;
      newTweet.threadId = threadId;
      newTweet.threadPosition = _currentThread.length;
      newTweet.threadTotalCount = _currentThread.length + 1;
      newTweet.isThreadStart = false;
      newTweet.isThreadEnd = true;
      newTweet.threadAuthorId = threadStarter.userId;
      
      // Save new tweet
      await _threadReference
          .child('tweets')
          .child(tweetKey!)
          .set(newTweet.toJson());
      
      // Update previous last tweet to not be thread end
      if (_currentThread.isNotEmpty) {
        final previousLast = _currentThread.last;
        previousLast.isThreadEnd = false;
        previousLast.threadTotalCount = _currentThread.length + 1;
        
        await _threadReference
            .child('tweets')
            .child(previousLast.key!)
            .update({
              'isThreadEnd': false,
              'threadTotalCount': _currentThread.length + 1,
            });
      }
      
      // Update thread metadata
      await _threadReference.child('threads').child(threadId).update({
        'tweetCount': _currentThread.length + 1,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      // Reload thread
      await loadThread(threadId);
      return true;
    } catch (e) {
      print('Error adding to thread: $e');
      return false;
    }
  }
  
  /// Get thread summary for display in timeline
  Future<List<FeedModel>> getThreadSummaries(int limit) async {
    try {
      final snapshot = await _threadReference
          .child('tweets')
          .orderByChild('isThreadStart')
          .equalTo(true)
          .limitToFirst(limit)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> tweetsData = snapshot.value as Map;
        List<FeedModel> threadStarters = [];
        
        for (var entry in tweetsData.entries) {
          final tweetData = Map<String, dynamic>.from(entry.value);
          tweetData['key'] = entry.key.toString();
          
          final tweet = FeedModel.fromJson(tweetData);
          if (tweet.isValidTweet) {
            threadStarters.add(tweet);
          }
        }
        
        return threadStarters;
      }
      return [];
    } catch (e) {
      print('Error getting thread summaries: $e');
      return [];
    }
  }
  
  /// Clear current thread data
  void clearCurrentThread() {
    _currentThread = [];
    _threadStarter = null;
    _currentThreadId = null;
    notifyListeners();
  }
  
  /// Check if user can add to thread
  bool canUserAddToCurrentThread(UserModel user) {
    if (_currentThreadId == null || _currentThread.isEmpty) {
      return false;
    }
    
    final lastTweet = _currentThread.last;
    return lastTweet.canUserAddToThread(user.userId);
  }
}
