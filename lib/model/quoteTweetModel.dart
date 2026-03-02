import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/user.dart';

class QuoteTweetModel {
  String? key;
  late String quotedTweetKey;
  FeedModel? quotedTweet;
  late String userId;
  String? description;
  late String createdAt;
  int? likeCount;
  int? retweetCount;
  int? commentCount;
  List<String>? likeList;
  String? imagePath;
  List<String>? tags;
  UserModel? user;
  
  QuoteTweetModel({
    this.key,
    required this.quotedTweetKey,
    this.quotedTweet,
    required this.userId,
    this.description,
    required this.createdAt,
    this.likeCount,
    this.retweetCount,
    this.commentCount,
    this.likeList,
    this.imagePath,
    this.tags,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'quotedTweetKey': quotedTweetKey,
      'quotedTweet': quotedTweet?.toJson(),
      'userId': userId,
      'description': description,
      'createdAt': createdAt,
      'likeCount': likeCount ?? 0,
      'retweetCount': retweetCount ?? 0,
      'commentCount': commentCount ?? 0,
      'likeList': likeList,
      'imagePath': imagePath,
      'tags': tags,
      'user': user?.toJson(),
    };
  }

  QuoteTweetModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    quotedTweetKey = map['quotedTweetKey'];
    
    if (map['quotedTweet'] != null) {
      quotedTweet = FeedModel.fromJson(map['quotedTweet']);
    }
    
    userId = map['userId'];
    description = map['description'];
    createdAt = map['createdAt'];
    likeCount = map['likeCount'] ?? 0;
    retweetCount = map['retweetCount'] ?? 0;
    commentCount = map['commentCount'] ?? 0;
    imagePath = map['imagePath'];
    
    user = map['user'] != null ? UserModel.fromJson(map['user']) : null;
    
    if (map['likeList'] != null) {
      likeList = <String>[];
      map['likeList'].forEach((value) {
        if (value is String) {
          likeList!.add(value);
        }
      });
      likeCount = likeList!.length;
    } else {
      likeList = [];
      likeCount = 0;
    }
    
    if (map['tags'] != null) {
      tags = <String>[];
      map['tags'].forEach((value) {
        tags!.add(value);
      });
    }
  }

  bool get isValidQuoteTweet {
    return user != null && 
           user!.userName != null && 
           user!.userName!.isNotEmpty &&
           quotedTweetKey.isNotEmpty;
  }

  /// Get combined text for display
  String get displayText {
    String result = description ?? '';
    if (quotedTweet?.description != null) {
      result += '\n\n${quotedTweet!.description}';
    }
    return result;
  }

  /// Check if user liked this quote tweet
  bool isLikedByUser(String userId) {
    return likeList?.contains(userId) ?? false;
  }

  /// Toggle like status
  void toggleLike(String userId) {
    if (isLikedByUser(userId)) {
      likeList?.remove(userId);
      likeCount = (likeCount ?? 1) - 1;
    } else {
      likeList?.add(userId);
      likeCount = (likeCount ?? 0) + 1;
    }
  }
}
