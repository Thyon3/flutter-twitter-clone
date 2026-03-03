import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitterclone/helper/enum.dart';
import 'package:twitterclone/helper/utility.dart';
import 'package:twitterclone/model/user.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'appState.dart';

enum SearchType {
  users,
  tweets,
  hashtags,
  media,
  all,
}

enum SearchFilter {
  all,
  verified,
  following,
  nearby,
  recent,
  popular,
}

enum TrendingType {
  hashtags,
  topics,
  users,
  news,
  entertainment,
  sports,
  technology,
}

extension SearchTypeExtension on SearchType {
  String get displayName {
    switch (this) {
      case SearchType.users:
        return 'Users';
      case SearchType.tweets:
        return 'Tweets';
      case SearchType.hashtags:
        return 'Hashtags';
      case SearchType.media:
        return 'Media';
      case SearchType.all:
        return 'All';
    }
  }

  static SearchType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'users':
        return SearchType.users;
      case 'tweets':
        return SearchType.tweets;
      case 'hashtags':
        return SearchType.hashtags;
      case 'media':
        return SearchType.media;
      case 'all':
        return SearchType.all;
      default:
        return SearchType.all;
    }
  }
}

extension SearchFilterExtension on SearchFilter {
  String get displayName {
    switch (this) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.verified:
        return 'Verified';
      case SearchFilter.following:
        return 'Following';
      case SearchFilter.nearby:
        return 'Nearby';
      case SearchFilter.recent:
        return 'Recent';
      case SearchFilter.popular:
        return 'Popular';
    }
  }

  static SearchFilter fromString(String filter) {
    switch (filter.toLowerCase()) {
      case 'all':
        return SearchFilter.all;
      case 'verified':
        return SearchFilter.verified;
      case 'following':
        return SearchFilter.following;
      case 'nearby':
        return SearchFilter.nearby;
      case 'recent':
        return SearchFilter.recent;
      case 'popular':
        return SearchFilter.popular;
      default:
        return SearchFilter.all;
    }
  }
}

extension TrendingTypeExtension on TrendingType {
  String get displayName {
    switch (this) {
      case TrendingType.hashtags:
        return 'Hashtags';
      case TrendingType.topics:
        return 'Topics';
      case TrendingType.users:
        return 'Users';
      case TrendingType.news:
        return 'News';
      case TrendingType.entertainment:
        return 'Entertainment';
      case TrendingType.sports:
        return 'Sports';
      case TrendingType.technology:
        return 'Technology';
    }
  }

  static TrendingType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'hashtags':
        return TrendingType.hashtags;
      case 'topics':
        return TrendingType.topics;
      case 'users':
        return TrendingType.users;
      case 'news':
        return TrendingType.news;
      case 'entertainment':
        return TrendingType.entertainment;
      case 'sports':
        return TrendingType.sports;
      case 'technology':
        return TrendingType.technology;
      default:
        return TrendingType.hashtags;
    }
  }
}

class SearchQuery {
  final String text;
  final SearchType type;
  final SearchFilter filter;
  final DateTime timestamp;
  final int? resultCount;

  SearchQuery({
    required this.text,
    this.type = SearchType.all,
    this.filter = SearchFilter.all,
    required this.timestamp,
    this.resultCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'type': type.name,
      'filter': filter.name,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      text: json['text'] ?? '',
      type: SearchTypeExtension.fromString(json['type'] ?? 'all'),
      filter: SearchFilterExtension.fromString(json['filter'] ?? 'all'),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      resultCount: json['resultCount'],
    );
  }
}

class TrendingItem {
  final String id;
  final String title;
  final String? description;
  final TrendingType type;
  final int tweetCount;
  final int? userCount;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isTrendingUp;
  final double? changePercentage;

  TrendingItem({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.tweetCount,
    this.userCount,
    this.imageUrl,
    required this.timestamp,
    this.isTrendingUp = true,
    this.changePercentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'tweetCount': tweetCount,
      'userCount': userCount,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isTrendingUp': isTrendingUp,
      'changePercentage': changePercentage,
    };
  }

  factory TrendingItem.fromJson(Map<String, dynamic> json) {
    return TrendingItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: TrendingTypeExtension.fromString(json['type'] ?? 'hashtags'),
      tweetCount: json['tweetCount'] ?? 0,
      userCount: json['userCount'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isTrendingUp: json['isTrendingUp'] ?? true,
      changePercentage: json['changePercentage']?.toDouble(),
    );
  }

  String get formattedTweetCount {
    if (tweetCount >= 1000000) {
      return '${(tweetCount / 1000000).toStringAsFixed(1)}M';
    } else if (tweetCount >= 1000) {
      return '${(tweetCount / 1000).toStringAsFixed(1)}K';
    }
    return tweetCount.toString();
  }

  String get changeDisplay {
    if (changePercentage == null) return '';
    final sign = isTrendingUp ? '+' : '';
    return '$sign${changePercentage!.toStringAsFixed(1)}%';
  }
}

class SearchState extends AppState {
  bool isBusy = false;
  SortUser sortBy = SortUser.MaxFollower;
  List<UserModel>? _userFilterList;
  List<UserModel>? _userlist;

  List<UserModel>? get userlist {
    if (_userFilterList == null) {
      return null;
    } else {
      return List.from(_userFilterList!);
    }
  }

  /// get [UserModel list] from firebase realtime Database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      kDatabase.child('profile').once().then(
        (DatabaseEvent event) {
          final snapshot = event.snapshot;
          _userlist = <UserModel>[];
          _userFilterList = <UserModel>[];
          if (snapshot.value != null) {
            var map = snapshot.value as Map?;
            if (map != null) {
              map.forEach((key, value) {
                var model = UserModel.fromJson(value);
                model.key = key;
                _userlist!.add(model);
                _userFilterList!.add(model);
              });
              _userFilterList!
                  .sort((x, y) => y.followers!.compareTo(x.followers!));
              notifyListeners();
            }
          } else {
            _userlist = null;
          }
          isBusy = false;
        },
      );
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_userlist != null && _userlist!.length != _userFilterList!.length) {
      _userFilterList = List.from(_userlist!);
      _userFilterList!.sort((x, y) => y.followers!.compareTo(x.followers!));
      // notifyListeners();
    }
  }

  /// This function call when search fiels text change.
  /// UserModel list on  search field get filter by `name` string
  void filterByUsername(String? name) {
    if (name != null &&
        name.isEmpty &&
        _userlist != null &&
        _userlist!.length != _userFilterList!.length) {
      _userFilterList = List.from(_userlist!);
    }
    // return if userList is empty or null
    if (_userlist == null && _userlist!.isEmpty) {
      cprint("User list is empty");
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      _userFilterList = _userlist!
          .where((x) =>
              x.userName != null &&
              x.userName!.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.Alphabetically:
        _userFilterList!
            .sort((x, y) => x.displayName!.compareTo(y.displayName!));
        return "Alphabetically";

      case SortUser.MaxFollower:
        _userFilterList!.sort((x, y) => y.followers!.compareTo(x.followers!));
        return "Popular";

      case SortUser.Newest:
        _userFilterList!.sort((x, y) => DateTime.parse(y.createdAt!)
            .compareTo(DateTime.parse(x.createdAt!)));
        return "Newest user";

      case SortUser.Oldest:
        _userFilterList!.sort((x, y) => DateTime.parse(x.createdAt!)
            .compareTo(DateTime.parse(y.createdAt!)));
        return "Oldest user";

      case SortUser.Verified:
        _userFilterList!.sort((x, y) =>
            y.isVerified.toString().compareTo(x.isVerified.toString()));
        return "Verified user";

      default:
        return "Unknown";
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<UserModel> userList = [];
  List<UserModel> getuserDetail(List<String> userIds) {
    final list = _userlist!.where((x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }
}
