import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/gifModel.dart';
import 'package:twitterclone/state/gifState.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';

class GifPickerWidget extends StatefulWidget {
  final Function(GifModel) onGifSelected;
  final bool allowStickers;
  
  const GifPickerWidget({
    Key? key,
    required this.onGifSelected,
    this.allowStickers = true,
  }) : super(key: key);

  @override
  _GifPickerWidgetState createState() => _GifPickerWidgetState();
}

class _GifPickerWidgetState extends State<GifPickerWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    
    // Initialize GIF state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GifState>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final gifState = context.read<GifState>();
    
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions.clear();
      });
    } else {
      // Get search suggestions
      gifState.getSearchSuggestions(query).then((suggestions) {
        if (mounted) {
          setState(() {
            _searchSuggestions = suggestions.take(5).toList();
            _showSuggestions = suggestions.isNotEmpty;
          });
        }
      });
      
      // Search for GIFs with debounce
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_searchController.text.trim() == query) {
          gifState.searchGifs(query);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Search bar
          _buildSearchBar(),
          
          // Search suggestions
          if (_showSuggestions)
            _buildSearchSuggestions(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrendingTab(),
                _buildCategoriesTab(),
                _buildSearchTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'GIF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search GIFs',
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<GifState>().clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _searchSuggestions.map((suggestion) {
          return InkWell(
            onTap: () {
              _searchController.text = suggestion;
              _onSearchChanged();
              setState(() {
                _showSuggestions = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendingTab() {
    return Consumer<GifState>(
      builder: (context, gifState, child) {
        return _buildGifGrid(
          gifs: gifState.trendingGifs,
          isLoading: gifState.isLoading,
          onRefresh: () => gifState.loadTrendingGifs(refresh: true),
          onLoadMore: gifState.hasMore ? () => gifState.loadTrendingGifs() : null,
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GifCategory.values.map((category) {
              return _buildCategoryChip(category);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(GifCategory category) {
    return Consumer<GifState>(
      builder: (context, gifState, child) {
        final isSelected = gifState.currentCategory == category;
        
        return ActionChip(
          label: Text(category.displayName),
          backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          onPressed: () {
            gifState.loadCategoryGifs(category, refresh: true);
            _tabController.animateTo(2); // Switch to search tab
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Consumer<GifState>(
      builder: (context, gifState, child) {
        if (gifState.currentCategory != null) {
          return _buildGifGrid(
            gifs: gifState.categoryGifs,
            isLoading: gifState.isLoading,
            onRefresh: () => gifState.loadCategoryGifs(gifState.currentCategory!, refresh: true),
            onLoadMore: gifState.hasMore ? () => gifState.loadCategoryGifs(gifState.currentCategory!) : null,
          );
        }
        
        return _buildGifGrid(
          gifs: gifState.searchResults,
          isLoading: gifState.isSearching,
          onRefresh: () => gifState.searchGifs(_searchController.text, refresh: true),
          onLoadMore: gifState.hasMore ? () => gifState.loadMoreSearchResults() : null,
          emptyMessage: _searchController.text.isNotEmpty 
              ? 'No GIFs found for "${_searchController.text}"'
              : 'Search for GIFs above',
        );
      },
    );
  }

  Widget _buildGifGrid({
    required List<GifModel> gifs,
    required bool isLoading,
    required VoidCallback onRefresh,
    VoidCallback? onLoadMore,
    String? emptyMessage,
  }) {
    if (isLoading && gifs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (gifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gif_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No GIFs available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.extentAfter < 200 &&
            onLoadMore != null) {
          onLoadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: gifs.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == gifs.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final gif = gifs[index];
            return _buildGifItem(gif);
          },
        ),
      ),
    );
  }

  Widget _buildGifItem(GifModel gif) {
    return GestureDetector(
      onTap: () {
        widget.onGifSelected(gif);
        Navigator.pop(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          gif.displayUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GifPickerBottomSheet extends StatelessWidget {
  final Function(GifModel) onGifSelected;
  final bool allowStickers;
  
  const GifPickerBottomSheet({
    Key? key,
    required this.onGifSelected,
    this.allowStickers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GifPickerWidget(
          onGifSelected: onGifSelected,
          allowStickers: allowStickers,
        );
      },
    );
  }
}
