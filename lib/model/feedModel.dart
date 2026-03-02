// ignore_for_file: avoid_print

import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/model/pollModel.dart';

class FeedModel {
  String? key;
  String? parentkey;
  String? childRetwetkey;
  String? description;
  late String userId;
  int? likeCount;
  List<String>? likeList;
  int? commentCount;
  int? retweetCount;
  late String createdAt;
  String? imagePath;
  List<String>? tags;
  List<String?>? replyTweetKeyList;
  String?
      lanCode; //Saving the language of the tweet so to not translate to check which language
  UserModel? user;
  
  // Thread support fields
  String? threadId; // ID to group all tweets in a thread
  int? threadPosition; // Position of this tweet in the thread (0, 1, 2...)
  int? threadTotalCount; // Total number of tweets in this thread
  bool? isThreadStart; // Is this the first tweet in a thread
  bool? isThreadEnd; // Is this the last tweet in a thread
  String? threadAuthorId; // Author of the thread (for multi-author threads)
  
  // Poll support
  PollModel? poll;
  
  FeedModel(
      {this.key,
      this.description,
      required this.userId,
      this.likeCount,
      this.commentCount,
      this.retweetCount,
      required this.createdAt,
      this.imagePath,
      this.likeList,
      this.tags,
      this.user,
      this.replyTweetKeyList,
      this.parentkey,
      this.lanCode,
      this.childRetwetkey,
      this.threadId,
      this.threadPosition,
      this.threadTotalCount,
      this.isThreadStart,
      this.isThreadEnd,
      this.threadAuthorId,
      this.poll});
  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount,
      "commentCount": commentCount ?? 0,
      "retweetCount": retweetCount ?? 0,
      "createdAt": createdAt,
      "imagePath": imagePath,
      "likeList": likeList,
      "tags": tags,
      "replyTweetKeyList": replyTweetKeyList,
      "user": user == null ? null : user!.toJson(),
      "parentkey": parentkey,
      "lanCode": lanCode,
      "childRetwetkey": childRetwetkey,
      "threadId": threadId,
      "threadPosition": threadPosition,
      "threadTotalCount": threadTotalCount,
      "isThreadStart": isThreadStart,
      "isThreadEnd": isThreadEnd,
      "threadAuthorId": threadAuthorId,
      "poll": poll?.toJson(),
    };
  }

  FeedModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    description = map['description'];
    userId = map['userId'];
    likeCount = map['likeCount'] ?? 0;
    commentCount = map['commentCount'];
    retweetCount = map["retweetCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'];
    imagePath = map['imagePath'];
    lanCode = map['lanCode'];
    user = UserModel.fromJson(map['user']);
    parentkey = map['parentkey'];
    childRetwetkey = map['childRetwetkey'];
    
    // Thread support fields
    threadId = map['threadId'];
    threadPosition = map['threadPosition'];
    threadTotalCount = map['threadTotalCount'];
    isThreadStart = map['isThreadStart'];
    isThreadEnd = map['isThreadEnd'];
    threadAuthorId = map['threadAuthorId'];
    
    // Poll support
    if (map['poll'] != null) {
      poll = PollModel.fromJson(map['poll']);
    }
    if (map['tags'] != null) {
      tags = <String>[];
      map['tags'].forEach((value) {
        tags!.add(value);
      });
    }
    if (map["likeList"] != null) {
      likeList = <String>[];

      final list = map['likeList'];

      /// In new tweet db schema likeList is stored as a List<String>()
      ///
      if (list is List) {
        map['likeList'].forEach((value) {
          if (value is String) {
            likeList!.add(value);
          }
        });
        likeCount = likeList!.length;
      }

      /// In old database tweet db schema likeList is saved in the form of map
      /// like list map is removed from latest code but to support old schema below code is required
      /// Once all user migrated to new version like list map support will be removed
      else if (list is Map) {
        list.forEach((key, value) {
          likeList!.add(value["userId"]);
        });
        likeCount = list.length;
      }
    } else {
      likeList = [];
      likeCount = 0;
    }
    if (map['replyTweetKeyList'] != null) {
      map['replyTweetKeyList'].forEach((value) {
        replyTweetKeyList = <String>[];
        map['replyTweetKeyList'].forEach((value) {
          replyTweetKeyList!.add(value);
        });
      });
      commentCount = replyTweetKeyList!.length;
    } else {
      replyTweetKeyList = [];
      commentCount = 0;
    }
  }

  bool get isValidTweet {
    bool isValid = false;
    if (user != null && user!.userName != null && user!.userName!.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Tweet found. Id:- $key");
    }
    return isValid;
  }

  /// get tweet key to retweet.
  ///
  /// If tweet [TweetType] is [TweetType.Retweet] and its description is null
  /// then its retweeted child tweet will be shared.
  String get getTweetKeyToRetweet {
    if (description == null && imagePath == null && childRetwetkey != null) {
      return childRetwetkey!;
    } else {
      return key!;
    }
  }

  /// Check if this tweet is part of a thread
  bool get isPartOfThread {
    return threadId != null && threadId!.isNotEmpty;
  }

  /// Check if this is a thread starter tweet
  bool get isThreadStarter {
    return isThreadStart == true;
  }

  /// Check if this is the last tweet in a thread
  bool get isThreadLast {
    return isThreadEnd == true;
  }

  /// Get thread position display text (e.g., "1/5")
  String? get threadPositionText {
    if (isPartOfThread && threadPosition != null && threadTotalCount != null) {
      return "${threadPosition! + 1}/$threadTotalCount";
    }
    return null;
  }

  /// Check if user can add to this thread
  bool canUserAddToThread(String userId) {
    return isPartOfThread && 
           !isThreadLast! && 
           (threadAuthorId == userId || this.userId == userId);
  }

  /// Check if this tweet contains a poll
  bool get hasPoll {
    return poll != null;
  }

  /// Check if user can vote in the poll
  bool canUserVoteInPoll(String userId) {
    return hasPoll && poll!.canUserVote(userId);
  }

  /// Check if user has voted in the poll
  bool hasUserVotedInPoll(String userId) {
    return hasPoll && poll!.hasUserVoted(userId);
  }
}
