import 'package:flutter/material.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/base/tweetBaseState.dart';

class ComposeTweetState extends TweetBaseState {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;
  String? _imagePath;
  List<String> _tags = [];
  
  // Getters
  TextEditingController get textController => _textController;
  bool get isPosting => _isPosting;
  String? get imagePath => _imagePath;
  List<String> get tags => _tags;
  
  int get characterCount => _textController.text.length;
  static const int maxCharacters = 280;
  
  bool get canPost {
    return !_isPosting && 
           characterCount <= maxCharacters && 
           characterCount > 0;
  }

  void initialize() {
    _textController.clear();
    _imagePath = null;
    _tags.clear();
    _isPosting = false;
    notifyListeners();
  }

  void setText(String text) {
    _textController.text = text;
    notifyListeners();
  }

  void appendText(String text) {
    _textController.text += text;
    notifyListeners();
  }

  void setImagePath(String? path) {
    _imagePath = path;
    notifyListeners();
  }

  void addTag(String tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  Future<bool> postTweet({
    String? description,
    String? imagePath,
    List<String>? tags,
    String? parentkey, // For replies
  }) async {
    try {
      _isPosting = true;
      notifyListeners();
      
      final authState = AuthState();
      final currentUser = authState.userModel;
      
      if (currentUser == null) {
        return false;
      }
      
      final tweetDescription = description ?? _textController.text.trim();
      final tweetImagePath = imagePath ?? _imagePath;
      final tweetTags = tags ?? _tags;
      
      if (tweetDescription.isEmpty) {
        return false;
      }
      
      // TODO: Implement actual tweet posting logic
      // This would involve:
      // 1. Uploading image to Firebase Storage if provided
      // 2. Creating tweet in Firebase Database
      // 3. Updating user's tweet count
      // 4. Notifying followers
      
      // Simulate network call
      await Future.delayed(const Duration(seconds: 1));
      
      // Clear form after successful post
      if (description == null) {
        initialize();
      }
      
      _isPosting = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error posting tweet: $e');
      _isPosting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> postReply({
    required String parentTweetId,
    String? description,
    String? imagePath,
    List<String>? tags,
  }) async {
    return postTweet(
      description: description,
      imagePath: imagePath,
      tags: tags,
      parentkey: parentTweetId,
    );
  }

  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
