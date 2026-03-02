class GifModel {
  String? id;
  String? url;
  String? title;
  String? username;
  int? width;
  int? height;
  String? previewUrl;
  String? thumbnailUrl;
  bool? isSticker;
  List<String>? tags;
  DateTime? createdAt;
  
  GifModel({
    this.id,
    this.url,
    this.title,
    this.username,
    this.width,
    this.height,
    this.previewUrl,
    this.thumbnailUrl,
    this.isSticker,
    this.tags,
    this.createdAt,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    // Handle Giphy API response format
    final images = json['images'];
    final original = images?['original'];
    final preview = images?['preview_gif'];
    final thumbnail = images?['fixed_height_small'];
    
    return GifModel(
      id: json['id'],
      url: original?['url'] ?? json['url'],
      title: json['title'],
      username: json['username'],
      width: original?['width'] != null ? int.tryParse(original['width'].toString()) : null,
      height: original?['height'] != null ? int.tryParse(original['height'].toString()) : null,
      previewUrl: preview?['url'],
      thumbnailUrl: thumbnail?['url'],
      isSticker: json['is_sticker'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: json['import_datetime'] != null 
          ? DateTime.tryParse(json['import_datetime']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'username': username,
      'width': width,
      'height': height,
      'previewUrl': previewUrl,
      'thumbnailUrl': thumbnailUrl,
      'isSticker': isSticker,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Get aspect ratio
  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return 1.0;
  }

  /// Check if this is a valid GIF
  bool get isValid {
    return id != null && 
           id!.isNotEmpty && 
           (url?.isNotEmpty ?? false) &&
           (thumbnailUrl?.isNotEmpty ?? false);
  }

  /// Get display URL (prefer thumbnail for better performance)
  String get displayUrl {
    return thumbnailUrl ?? previewUrl ?? url ?? '';
  }

  /// Get original URL for high quality
  String get originalUrl {
    return url ?? displayUrl;
  }

  /// Check if GIF is trending (based on creation date)
  bool get isTrending {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inDays <= 7; // Consider trending if created within 7 days
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GifModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode ?? 0;

  @override
  String toString() {
    return 'GifModel{id: $id, title: $title, url: $url}';
  }
}

class GifSearchResult {
  List<GifModel> gifs;
  int totalCount;
  int? offset;
  int? count;
  
  GifSearchResult({
    required this.gifs,
    required this.totalCount,
    this.offset,
    this.count,
  });

  factory GifSearchResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    
    final gifs = data.map((gifJson) => GifModel.fromJson(gifJson)).toList();
    
    return GifSearchResult(
      gifs: gifs,
      totalCount: pagination['total_count'] ?? gifs.length,
      offset: pagination['offset'],
      count: pagination['count'],
    );
  }

  /// Check if there are more results
  bool get hasMore {
    if (offset == null || count == null) return false;
    return (offset! + count!) < totalCount;
  }

  /// Get next offset for pagination
  int get nextOffset {
    return (offset ?? 0) + (count ?? gifs.length);
  }
}

enum GifCategory {
  trending,
  reactions,
  entertainment,
  sports,
  stickers,
  artists,
  gaming,
  anime,
}

extension GifCategoryExtension on GifCategory {
  String get displayName {
    switch (this) {
      case GifCategory.trending:
        return 'Trending';
      case GifCategory.reactions:
        return 'Reactions';
      case GifCategory.entertainment:
        return 'Entertainment';
      case GifCategory.sports:
        return 'Sports';
      case GifCategory.stickers:
        return 'Stickers';
      case GifCategory.artists:
        return 'Artists';
      case GifCategory.gaming:
        return 'Gaming';
      case GifCategory.anime:
        return 'Anime';
    }
  }

  String get searchQuery {
    switch (this) {
      case GifCategory.trending:
        return 'trending';
      case GifCategory.reactions:
        return 'reactions';
      case GifCategory.entertainment:
        return 'entertainment';
      case GifCategory.sports:
        return 'sports';
      case GifCategory.stickers:
        return 'stickers';
      case GifCategory.artists:
        return 'artists';
      case GifCategory.gaming:
        return 'gaming';
      case GifCategory.anime:
        return 'anime';
    }
  }
}
