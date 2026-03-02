import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twitterclone/model/gifModel.dart';

class GifService {
  static const String _baseUrl = 'https://api.giphy.com/v1/gifs';
  static const String _apiKey = 'YOUR_GIPHY_API_KEY'; // Replace with actual API key
  
  // Rate limiting
  static const int _maxRequestsPerHour = 1000;
  static int _requestCount = 0;
  static DateTime? _lastReset;
  
  /// Initialize the service
  static void initialize() {
    _lastReset = DateTime.now();
    _requestCount = 0;
  }
  
  /// Check if we can make a request (rate limiting)
  static bool _canMakeRequest() {
    final now = DateTime.now();
    if (_lastReset == null || now.difference(_lastReset!).inHours >= 1) {
      _lastReset = now;
      _requestCount = 0;
      return true;
    }
    return _requestCount < _maxRequestsPerHour;
  }
  
  /// Make HTTP request with error handling
  static Future<Map<String, dynamic>?> _makeRequest(String url) async {
    if (!_canMakeRequest()) {
      throw Exception('Rate limit exceeded. Please try again later.');
    }
    
    try {
      _requestCount++;
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load GIFs: ${response.statusCode}');
      }
    } catch (e) {
      print('GifService error: $e');
      rethrow;
    }
  }
  
  /// Search for GIFs
  static Future<GifSearchResult> searchGifs({
    required String query,
    int limit = 25,
    int offset = 0,
    String rating = 'g',
    String lang = 'en',
  }) async {
    if (query.trim().isEmpty) {
      return getTrendingGifs(limit: limit, offset: offset);
    }
    
    final url = '$_baseUrl/search?api_key=$_apiKey&q=${Uri.encodeComponent(query)}&limit=$limit&offset=$offset&rating=$rating&lang=$lang';
    
    try {
      final response = await _makeRequest(url);
      if (response != null) {
        return GifSearchResult.fromJson(response);
      }
      return GifSearchResult(gifs: [], totalCount: 0);
    } catch (e) {
      print('Error searching GIFs: $e');
      return GifSearchResult(gifs: [], totalCount: 0);
    }
  }
  
  /// Get trending GIFs
  static Future<GifSearchResult> getTrendingGifs({
    int limit = 25,
    int offset = 0,
    String rating = 'g',
  }) async {
    final url = '$_baseUrl/trending?api_key=$_apiKey&limit=$limit&offset=$offset&rating=$rating';
    
    try {
      final response = await _makeRequest(url);
      if (response != null) {
        return GifSearchResult.fromJson(response);
      }
      return GifSearchResult(gifs: [], totalCount: 0);
    } catch (e) {
      print('Error getting trending GIFs: $e');
      return GifSearchResult(gifs: [], totalCount: 0);
    }
  }
  
  /// Get GIFs by category
  static Future<GifSearchResult> getCategoryGifs({
    required GifCategory category,
    int limit = 25,
    int offset = 0,
    String rating = 'g',
  }) async {
    return searchGifs(
      query: category.searchQuery,
      limit: limit,
      offset: offset,
      rating: rating,
    );
  }
  
  /// Get GIF by ID
  static Future<GifModel?> getGifById(String gifId) async {
    final url = '$_baseUrl/$gifId?api_key=$_apiKey';
    
    try {
      final response = await _makeRequest(url);
      if (response != null && response['data'] != null) {
        return GifModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting GIF by ID: $e');
      return null;
    }
  }
  
  /// Get random GIF
  static Future<GifModel?> getRandomGif({
    String? tag,
    String rating = 'g',
  }) async {
    String url = '$_baseUrl/random?api_key=$_apiKey&rating=$rating';
    if (tag != null && tag.isNotEmpty) {
      url += '&tag=${Uri.encodeComponent(tag)}';
    }
    
    try {
      final response = await _makeRequest(url);
      if (response != null && response['data'] != null) {
        return GifModel.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print('Error getting random GIF: $e');
      return null;
    }
  }
  
  /// Get related GIFs
  static Future<GifSearchResult> getRelatedGifs({
    required String gifId,
    int limit = 10,
  }) async {
    final url = '$_baseUrl/related?api_key=$_apiKey&gif_id=$gifId&limit=$limit';
    
    try {
      final response = await _makeRequest(url);
      if (response != null) {
        return GifSearchResult.fromJson(response);
      }
      return GifSearchResult(gifs: [], totalCount: 0);
    } catch (e) {
      print('Error getting related GIFs: $e');
      return GifSearchResult(gifs: [], totalCount: 0);
    }
  }
  
  /// Search suggestions (autocomplete)
  static Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];
    
    final url = 'https://api.giphy.com/v1/gifs/search/tags?api_key=$_apiKey&q=${Uri.encodeComponent(query)}&limit=$limit';
    
    try {
      final response = await _makeRequest(url);
      if (response != null && response['data'] != null) {
        final tags = response['data'] as List;
        return tags.map((tag) => tag['name']?.toString() ?? '').where((name) => name.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      print('Error getting search suggestions: $e');
      return [];
    }
  }
  
  /// Validate API key
  static Future<bool> validateApiKey() async {
    if (_apiKey == 'YOUR_GIPHY_API_KEY') {
      return false;
    }
    
    try {
      final result = await getTrendingGifs(limit: 1);
      return result.gifs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Get service status
  static Map<String, dynamic> getServiceStatus() {
    return {
      'isRateLimited': !_canMakeRequest(),
      'requestsMade': _requestCount,
      'maxRequestsPerHour': _maxRequestsPerHour,
      'lastReset': _lastReset?.toIso8601String(),
      'apiKeyConfigured': _apiKey != 'YOUR_GIPHY_API_KEY',
    };
  }
  
  /// Reset rate limit (for testing)
  static void resetRateLimit() {
    _requestCount = 0;
    _lastReset = DateTime.now();
  }
}
