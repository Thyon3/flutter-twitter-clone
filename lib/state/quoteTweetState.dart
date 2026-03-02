import 'package:firebase_database/firebase_database.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/quoteTweetModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/base/tweetBaseState.dart';

class QuoteTweetState extends TweetBaseState {
  final DatabaseReference _quoteTweetReference = FirebaseDatabase.instance.ref();
  
  List<QuoteTweetModel> _userQuoteTweets = [];
  List<QuoteTweetModel> _feedQuoteTweets = [];
  bool _isLoading = false;
  bool _isCreatingQuote = false;
  
  // Getters
  List<QuoteTweetModel> get userQuoteTweets => _userQuoteTweets;
  List<QuoteTweetModel> get feedQuoteTweets => _feedQuoteTweets;
  bool get isLoading => _isLoading;
  bool get isCreatingQuote => _isCreatingQuote;
  
  /// Create a new quote tweet
  Future<String?> createQuoteTweet({
    required String quotedTweetKey,
    required String description,
    String? imagePath,
    List<String>? tags,
  }) async {
    try {
      _isCreatingQuote = true;
      notifyListeners();
      
      final authState = AuthState();
      final currentUser = authState.userModel;
      
      if (currentUser == null) {
        return null;
      }
      
      // Get the quoted tweet details
      final quotedTweetSnapshot = await _quoteTweetReference
          .child('tweets')
          .child(quotedTweetKey)
          .get();
      
      if (!quotedTweetSnapshot.exists) {
        return null;
      }
      
      final quotedTweetData = Map<String, dynamic>.from(quotedTweetSnapshot.value as Map);
      quotedTweetData['key'] = quotedTweetKey;
      final quotedTweet = FeedModel.fromJson(quotedTweetData);
      
      // Create quote tweet
      final quoteTweetKey = _quoteTweetReference.child('quoteTweets').push().key;
      final quoteTweet = QuoteTweetModel(
        key: quoteTweetKey,
        quotedTweetKey: quotedTweetKey,
        quotedTweet: quotedTweet,
        userId: currentUser.userId,
        description: description,
        createdAt: DateTime.now().toIso8601String(),
        imagePath: imagePath,
        tags: tags,
        user: currentUser,
      );
      
      // Save to database
      await _quoteTweetReference
          .child('quoteTweets')
          .child(quoteTweetKey!)
          .set(quoteTweet.toJson());
      
      // Update quoted tweet's quote count
      await _quoteTweetReference
          .child('tweets')
          .child(quotedTweetKey)
          .update({
            'quoteCount': ServerValue.increment(1),
          });
      
      // Add to user's quote tweets
      _userQuoteTweets.insert(0, quoteTweet);
      _feedQuoteTweets.insert(0, quoteTweet);
      
      _isCreatingQuote = false;
      notifyListeners();
      
      return quoteTweetKey;
    } catch (e) {
      print('Error creating quote tweet: $e');
      _isCreatingQuote = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Load user's quote tweets
  Future<void> loadUserQuoteTweets(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _quoteTweetReference
          .child('quoteTweets')
          .orderByChild('userId')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> quoteTweetsData = snapshot.value as Map;
        List<QuoteTweetModel> quoteTweets = [];
        
        for (var entry in quoteTweetsData.entries) {
          final quoteTweetData = Map<String, dynamic>.from(entry.value);
          quoteTweetData['key'] = entry.key.toString();
          
          final quoteTweet = QuoteTweetModel.fromJson(quoteTweetData);
          if (quoteTweet.isValidQuoteTweet) {
            quoteTweets.add(quoteTweet);
          }
        }
        
        // Sort by creation time (newest first)
        quoteTweets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _userQuoteTweets = quoteTweets;
      }
    } catch (e) {
      print('Error loading user quote tweets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load quote tweets for feed
  Future<void> loadFeedQuoteTweets({int limit = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await _quoteTweetReference
          .child('quoteTweets')
          .orderByChild('createdAt')
          .limitToFirst(limit)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> quoteTweetsData = snapshot.value as Map;
        List<QuoteTweetModel> quoteTweets = [];
        
        for (var entry in quoteTweetsData.entries) {
          final quoteTweetData = Map<String, dynamic>.from(entry.value);
          quoteTweetData['key'] = entry.key.toString();
          
          final quoteTweet = QuoteTweetModel.fromJson(quoteTweetData);
          if (quoteTweet.isValidQuoteTweet) {
            quoteTweets.add(quoteTweet);
          }
        }
        
        // Sort by creation time (newest first)
        quoteTweets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _feedQuoteTweets = quoteTweets;
      }
    } catch (e) {
      print('Error loading feed quote tweets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Like or unlike a quote tweet
  Future<bool> toggleLikeQuoteTweet(String quoteTweetKey) async {
    try {
      final authState = AuthState();
      final currentUserId = authState.userModel?.userId;
      
      if (currentUserId == null) {
        return false;
      }
      
      // Find the quote tweet in local lists
      QuoteTweetModel? quoteTweet;
      int? userIndex;
      int? feedIndex;
      
      for (int i = 0; i < _userQuoteTweets.length; i++) {
        if (_userQuoteTweets[i].key == quoteTweetKey) {
          quoteTweet = _userQuoteTweets[i];
          userIndex = i;
          break;
        }
      }
      
      if (quoteTweet == null) {
        for (int i = 0; i < _feedQuoteTweets.length; i++) {
          if (_feedQuoteTweets[i].key == quoteTweetKey) {
            quoteTweet = _feedQuoteTweets[i];
            feedIndex = i;
            break;
          }
        }
      }
      
      if (quoteTweet == null) {
        return false;
      }
      
      // Toggle like status
      final wasLiked = quoteTweet.isLikedByUser(currentUserId);
      quoteTweet.toggleLike(currentUserId);
      
      // Update in database
      await _quoteTweetReference
          .child('quoteTweets')
          .child(quoteTweetKey)
          .update({
            'likeList': quoteTweet.likeList,
            'likeCount': quoteTweet.likeCount,
          });
      
      // Update local lists
      if (userIndex != null) {
        _userQuoteTweets[userIndex] = quoteTweet;
      }
      if (feedIndex != null) {
        _feedQuoteTweets[feedIndex] = quoteTweet;
      }
      
      notifyListeners();
      return !wasLiked;
    } catch (e) {
      print('Error toggling like on quote tweet: $e');
      return false;
    }
  }
  
  /// Delete a quote tweet
  Future<bool> deleteQuoteTweet(String quoteTweetKey) async {
    try {
      final authState = AuthState();
      final currentUserId = authState.userModel?.userId;
      
      if (currentUserId == null) {
        return false;
      }
      
      // Find the quote tweet
      QuoteTweetModel? quoteTweet;
      int? userIndex;
      int? feedIndex;
      
      for (int i = 0; i < _userQuoteTweets.length; i++) {
        if (_userQuoteTweets[i].key == quoteTweetKey) {
          quoteTweet = _userQuoteTweets[i];
          userIndex = i;
          break;
        }
      }
      
      if (quoteTweet == null || quoteTweet.userId != currentUserId) {
        return false;
      }
      
      // Delete from database
      await _quoteTweetReference
          .child('quoteTweets')
          .child(quoteTweetKey)
          .remove();
      
      // Update quoted tweet's quote count
      await _quoteTweetReference
          .child('tweets')
          .child(quoteTweet.quotedTweetKey)
          .update({
            'quoteCount': ServerValue.increment(-1),
          });
      
      // Remove from local lists
      if (userIndex != null) {
        _userQuoteTweets.removeAt(userIndex);
      }
      for (int i = 0; i < _feedQuoteTweets.length; i++) {
        if (_feedQuoteTweets[i].key == quoteTweetKey) {
          feedIndex = i;
          break;
        }
      }
      if (feedIndex != null) {
        _feedQuoteTweets.removeAt(feedIndex);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting quote tweet: $e');
      return false;
    }
  }
  
  /// Get quote tweet by key
  QuoteTweetModel? getQuoteTweetByKey(String key) {
    try {
      for (var quoteTweet in _userQuoteTweets) {
        if (quoteTweet.key == key) {
          return quoteTweet;
        }
      }
      for (var quoteTweet in _feedQuoteTweets) {
        if (quoteTweet.key == key) {
          return quoteTweet;
        }
      }
      return null;
    } catch (e) {
      print('Error getting quote tweet by key: $e');
      return null;
    }
  }
  
  /// Clear all quote tweets
  void clearAll() {
    _userQuoteTweets.clear();
    _feedQuoteTweets.clear();
    notifyListeners();
  }
  
  /// Get quote tweets for a specific quoted tweet
  List<QuoteTweetModel> getQuotesForTweet(String quotedTweetKey) {
    return _feedQuoteTweets
        .where((quote) => quote.quotedTweetKey == quotedTweetKey)
        .toList();
  }
}
