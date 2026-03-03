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
  bool _isLoading = false;
  String? _error;
  SortUser sortBy = SortUser.MaxFollower;
  
  // Search properties
  String _currentQuery = '';
  SearchType _currentSearchType = SearchType.all;
  SearchFilter _currentFilter = SearchFilter.all;
  List<SearchQuery> _searchHistory = [];
  List<TrendingItem> _trendingItems = [];
  
  // Results
  List<UserModel>? _userFilterList;
  List<UserModel>? _userlist;
  List<FeedModel>? _tweetResults;
  List<String>? _hashtagResults;
  List<FeedModel>? _mediaResults;
  
  // Pagination
  int _userPage = 0;
  int _tweetPage = 0;
  bool _hasMoreUsers = true;
  bool _hasMoreTweets = true;
  final int _pageSize = 20;
  
  // Getters
  List<UserModel>? get userlist {
    if (_userFilterList == null) {
      return null;
    } else {
      return List.from(_userFilterList!);
    }
  }
  
  String get currentQuery => _currentQuery;
  SearchType get currentSearchType => _currentSearchType;
  SearchFilter get currentFilter => _currentFilter;
  List<SearchQuery> get searchHistory => List.from(_searchHistory);
  List<TrendingItem> get trendingItems => List.from(_trendingItems);
  List<FeedModel>? get tweetResults => _tweetResults;
  List<String>? get hashtagResults => _hashtagResults;
  List<FeedModel>? get mediaResults => _mediaResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSearchHistory => _searchHistory.isNotEmpty;
  bool get hasTrendingItems => _trendingItems.isNotEmpty;
  bool get hasMoreUsers => _hasMoreUsers;
  bool get hasMoreTweets => _hasMoreTweets;
  bool get hasQuery => _currentQuery.isNotEmpty;
  
  /// Initialize search state
  Future<void> initialize() async {
    await Future.wait([
      loadSearchHistory(),
      loadTrendingItems(),
    ]);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Reset search state
  void resetSearch() {
    _currentQuery = '';
    _userFilterList = null;
    _tweetResults = null;
    _hashtagResults = null;
    _mediaResults = null;
    _userPage = 0;
    _tweetPage = 0;
    _hasMoreUsers = true;
    _hasMoreTweets = true;
    _error = null;
    notifyListeners();
  }
  
  /// Set search query
  void setQuery(String query) {
    _currentQuery = query;
    notifyListeners();
  }
  
  /// Set search type
  void setSearchType(SearchType type) {
    _currentSearchType = type;
    notifyListeners();
  }
  
  /// Set search filter
  void setFilter(SearchFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Load search history from local storage
  Future<void> loadSearchHistory() async {
    try {
      // This would load from SharedPreferences or similar
      // For now, using empty list
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load search history: $e';
      notifyListeners();
    }
  }

  /// Save search query to history
  Future<void> saveSearchToHistory(String query, SearchType type, int resultCount) async {
    try {
      // Remove existing query if present
      _searchHistory.removeWhere((item) => item.text == query);
      
      // Add new query to beginning
      final searchQuery = SearchQuery(
        text: query,
        type: type,
        timestamp: DateTime.now(),
        resultCount: resultCount,
      );
      
      _searchHistory.insert(0, searchQuery);
      
      // Keep only last 50 searches
      if (_searchHistory.length > 50) {
        _searchHistory = _searchHistory.take(50).toList();
      }
      
      // Save to local storage
      await _saveSearchHistoryToStorage();
      notifyListeners();
    } catch (e) {
      print('Error saving search to history: $e');
    }
  }

  /// Remove search query from history
  Future<void> removeFromSearchHistory(String query) async {
    try {
      _searchHistory.removeWhere((item) => item.text == query);
      await _saveSearchHistoryToStorage();
      notifyListeners();
    } catch (e) {
      print('Error removing from search history: $e');
    }
  }

  /// Clear all search history
  Future<void> clearSearchHistory() async {
    try {
      _searchHistory.clear();
      await _saveSearchHistoryToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear search history: $e';
      notifyListeners();
    }
  }

  /// Save search history to local storage
  Future<void> _saveSearchHistoryToStorage() async {
    try {
      // This would save to SharedPreferences or similar
      // For now, just print the data
      final historyJson = _searchHistory.map((item) => item.toJson()).toList();
      print('Saving search history: $historyJson');
    } catch (e) {
      print('Error saving search history to storage: $e');
    }
  }

  /// Get recent search queries (last 10)
  List<SearchQuery> getRecentSearches() {
    return _searchHistory.take(10).toList();
  }

  /// Get popular search queries (most frequent)
  List<SearchQuery> getPopularSearches() {
    final queryCounts = <String, int>{};
    
    for (final query in _searchHistory) {
      queryCounts[query.text] = (queryCounts[query.text] ?? 0) + 1;
    }
    
    final sortedQueries = queryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedQueries
        .take(10)
        .map((entry) => _searchHistory
            .firstWhere((query) => query.text == entry.key))
        .toList();
  }

  /// Load trending items from database
  Future<void> loadTrendingItems() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // For demo, create sample trending items
      _trendingItems = [
        TrendingItem(
          id: '1',
          title: '#FlutterDev',
          description: 'Flutter development discussions',
          type: TrendingType.hashtags,
          tweetCount: 15420,
          userCount: 3200,
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          isTrendingUp: true,
          changePercentage: 15.3,
        ),
        TrendingItem(
          id: '2',
          title: 'Tech News',
          description: 'Latest technology updates',
          type: TrendingType.technology,
          tweetCount: 8750,
          userCount: 2100,
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          isTrendingUp: true,
          changePercentage: 8.7,
        ),
        TrendingItem(
          id: '3',
          title: 'World Cup',
          description: 'Sports championship updates',
          type: TrendingType.sports,
          tweetCount: 25600,
          userCount: 5400,
          timestamp: DateTime.now().subtract(Duration(hours: 1)),
          isTrendingUp: false,
          changePercentage: -2.1,
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load trending items: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh trending items
  Future<void> refreshTrendingItems() async {
    await loadTrendingItems();
  }

  /// Get trending items by type
  List<TrendingItem> getTrendingItemsByType(TrendingType type) {
    return _trendingItems.where((item) => item.type == type).toList();
  }

  /// Get top trending items (overall)
  List<TrendingItem> getTopTrendingItems({int limit = 10}) {
    final sortedItems = List<TrendingItem>.from(_trendingItems)
      ..sort((a, b) => b.tweetCount.compareTo(a.tweetCount));
    return sortedItems.take(limit).toList();
  }

  /// Get rising trending items (highest percentage increase)
  List<TrendingItem> getRisingTrendingItems({int limit = 5}) {
    final risingItems = _trendingItems
        .where((item) => item.isTrendingUp && item.changePercentage != null)
        .toList()
      ..sort((a, b) => b.changePercentage!.compareTo(a.changePercentage!));
    return risingItems.take(limit).toList();
  }

  /// Add custom trending item
  Future<void> addTrendingItem(TrendingItem item) async {
    try {
      _trendingItems.insert(0, item);
      await _saveTrendingItemsToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add trending item: $e';
      notifyListeners();
    }
  }

  /// Remove trending item
  Future<void> removeTrendingItem(String itemId) async {
    try {
      _trendingItems.removeWhere((item) => item.id == itemId);
      await _saveTrendingItemsToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove trending item: $e';
      notifyListeners();
    }
  }

  /// Save trending items to storage
  Future<void> _saveTrendingItemsToStorage() async {
    try {
      final trendingJson = _trendingItems.map((item) => item.toJson()).toList();
      print('Saving trending items: $trendingJson');
    } catch (e) {
      print('Error saving trending items to storage: $e');
    }
  }

  /// Search users by query
  Future<void> searchUsers(String query, {bool loadMore = false}) async {
    try {
      if (!loadMore) {
        _isLoading = true;
        _userPage = 0;
        _hasMoreUsers = true;
        _userFilterList = [];
      }
      
      if (!_hasMoreUsers) return;
      
      notifyListeners();
      
      final snapshot = await kDatabase
          .child('profile')
          .orderByChild('displayName')
          .startAt(query.toLowerCase())
          .endAt(query.toLowerCase() + '\uf8ff')
          .limitToFirst(_pageSize)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map;
        List<UserModel> users = [];
        
        for (var entry in usersData.entries) {
          final userData = Map<String, dynamic>.from(entry.value);
          userData['key'] = entry.key.toString();
          
          final user = UserModel.fromJson(userData);
          
          // Apply filters
          if (_shouldIncludeUser(user)) {
            users.add(user);
          }
        }
        
        if (loadMore) {
          _userFilterList!.addAll(users);
        } else {
          _userFilterList = users;
        }
        
        _userPage++;
        _hasMoreUsers = users.length == _pageSize;
      } else {
        _hasMoreUsers = false;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user should be included based on current filter
  bool _shouldIncludeUser(UserModel user) {
    switch (_currentFilter) {
      case SearchFilter.verified:
        return user.isVerified ?? false;
      case SearchFilter.following:
        // This would check if current user follows this user
        return false; // Placeholder
      case SearchFilter.all:
      default:
        return true;
    }
  }

  /// Load more users
  Future<void> loadMoreUsers() async {
    if (_currentQuery.isNotEmpty) {
      await searchUsers(_currentQuery, loadMore: true);
    }
  }

  /// Search users by username
  Future<void> searchUsersByUsername(String username) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final snapshot = await kDatabase
          .child('profile')
          .orderByChild('userName')
          .equalTo(username)
          .get();
      
      if (snapshot.exists) {
        final Map<dynamic, dynamic> usersData = snapshot.value as Map;
        List<UserModel> users = [];
        
        for (var entry in usersData.entries) {
          final userData = Map<String, dynamic>.from(entry.value);
          userData['key'] = entry.key.toString();
          
          final user = UserModel.fromJson(userData);
          users.add(user);
        }
        
        _userFilterList = users;
      } else {
        _userFilterList = [];
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search users by username: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search users by location
  Future<void> searchUsersByLocation(String location) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // This would implement location-based search
      // For now, return empty list
      _userFilterList = [];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search users by location: $e';
      _isLoading = false;
      notifyListeners();
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
