import 'package:flutter/material.dart';
import 'package:twitterclone/model/gifModel.dart';
import 'package:twitterclone/resource/gifService.dart';

class GifState extends ChangeNotifier {
  List<GifModel> _trendingGifs = [];
  List<GifModel> _searchResults = [];
  List<GifModel> _categoryGifs = [];
  Map<GifCategory, List<GifModel>> _categoryCache = {};
  
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  String? _currentQuery;
  GifCategory? _currentCategory;
  
  String? _error;
  int _searchOffset = 0;
  int _trendingOffset = 0;
  int _categoryOffset = 0;
  
  // Selected GIF for composition
  GifModel? _selectedGif;
  
  // Getters
  List<GifModel> get trendingGifs => _trendingGifs;
  List<GifModel> get searchResults => _searchResults;
  List<GifModel> get categoryGifs => _categoryGifs;
  Map<GifCategory, List<GifModel>> get categoryCache => _categoryCache;
  
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String? get currentQuery => _currentQuery;
  GifCategory? get currentCategory => _currentCategory;
  
  GifModel? get selectedGif => _selectedGif;
  
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get hasTrendingGifs => _trendingGifs.isNotEmpty;
  bool get hasCategoryGifs => _categoryGifs.isNotEmpty;
  
  /// Initialize GIF service
  Future<void> initialize() async {
    try {
      GifService.initialize();
      await loadTrendingGifs();
    } catch (e) {
      _error = 'Failed to initialize GIF service: $e';
      notifyListeners();
    }
  }
  
  /// Load trending GIFs
  Future<void> loadTrendingGifs({bool refresh = false}) async {
    if (refresh) {
      _trendingOffset = 0;
      _trendingGifs.clear();
    }
    
    if (_isLoading && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await GifService.getTrendingGifs(
        limit: 25,
        offset: _trendingOffset,
      );
      
      if (refresh) {
        _trendingGifs = result.gifs;
      } else {
        _trendingGifs.addAll(result.gifs);
      }
      
      _trendingOffset = result.nextOffset;
      _error = null;
    } catch (e) {
      _error = 'Failed to load trending GIFs: $e';
      print('Error loading trending GIFs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Search for GIFs
  Future<void> searchGifs(String query, {bool reset = true}) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _currentQuery = null;
      notifyListeners();
      return;
    }
    
    if (reset) {
      _searchOffset = 0;
      _searchResults.clear();
      _currentQuery = query;
    }
    
    if (_isSearching && !reset) return;
    
    _isSearching = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await GifService.searchGifs(
        query: query,
        limit: 25,
        offset: _searchOffset,
      );
      
      if (reset) {
        _searchResults = result.gifs;
      } else {
        _searchResults.addAll(result.gifs);
      }
      
      _searchOffset = result.nextOffset;
      _error = null;
    } catch (e) {
      _error = 'Failed to search GIFs: $e';
      print('Error searching GIFs: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  /// Load more search results
  Future<void> loadMoreSearchResults() async {
    if (_currentQuery == null || _isLoadingMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      await searchGifs(_currentQuery!, reset: false);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// Load category GIFs
  Future<void> loadCategoryGifs(GifCategory category, {bool refresh = false}) async {
    if (refresh) {
      _categoryOffset = 0;
      _categoryGifs.clear();
      _categoryCache.remove(category);
    }
    
    // Check cache first
    if (!refresh && _categoryCache.containsKey(category)) {
      _categoryGifs = _categoryCache[category]!;
      _currentCategory = category;
      notifyListeners();
      return;
    }
    
    if (_isLoading && !refresh) return;
    
    _isLoading = true;
    _error = null;
    _currentCategory = category;
    notifyListeners();
    
    try {
      final result = await GifService.getCategoryGifs(
        category: category,
        limit: 25,
        offset: _categoryOffset,
      );
      
      if (refresh) {
        _categoryGifs = result.gifs;
      } else {
        _categoryGifs.addAll(result.gifs);
      }
      
      _categoryOffset = result.nextOffset;
      _categoryCache[category] = List.from(_categoryGifs);
      _error = null;
    } catch (e) {
      _error = 'Failed to load category GIFs: $e';
      print('Error loading category GIFs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Get random GIF
  Future<GifModel?> getRandomGif({String? tag}) async {
    try {
      return await GifService.getRandomGif(tag: tag);
    } catch (e) {
      _error = 'Failed to get random GIF: $e';
      notifyListeners();
      return null;
    }
  }
  
  /// Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      return await GifService.getSearchSuggestions(query: query);
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }
  
  /// Select a GIF
  void selectGif(GifModel gif) {
    _selectedGif = gif;
    notifyListeners();
  }
  
  /// Clear selected GIF
  void clearSelectedGif() {
    _selectedGif = null;
    notifyListeners();
  }
  
  /// Clear search results
  void clearSearch() {
    _searchResults.clear();
    _currentQuery = null;
    _searchOffset = 0;
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Refresh current data
  Future<void> refresh() async {
    if (_currentQuery != null) {
      await searchGifs(_currentQuery!, refresh: true);
    } else if (_currentCategory != null) {
      await loadCategoryGifs(_currentCategory!, refresh: true);
    } else {
      await loadTrendingGifs(refresh: true);
    }
  }
  
  /// Check if service is available
  bool get isServiceAvailable {
    final status = GifService.getServiceStatus();
    return status['apiKeyConfigured'] == true && !status['isRateLimited'];
  }
  
  /// Get service status
  Map<String, dynamic> get serviceStatus => GifService.getServiceStatus();
  
  /// Reset all state
  void reset() {
    _trendingGifs.clear();
    _searchResults.clear();
    _categoryGifs.clear();
    _categoryCache.clear();
    _selectedGif = null;
    _currentQuery = null;
    _currentCategory = null;
    _error = null;
    _searchOffset = 0;
    _trendingOffset = 0;
    _categoryOffset = 0;
    _isLoading = false;
    _isSearching = false;
    _isLoadingMore = false;
    notifyListeners();
  }
}
