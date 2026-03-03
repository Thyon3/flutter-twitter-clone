import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/feedState.dart';
import 'package:twitterclone/state/pollState.dart';
import 'package:twitterclone/state/gifState.dart';
import 'package:twitterclone/ui/page/feed/composePoll.dart';
import 'package:twitterclone/widgets/tweet/gif_picker_widget.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';

class ComposeTweetPage extends StatefulWidget {
  final bool isRetweet;
  final bool isTweet;

  const ComposeTweetPage({
    Key? key,
    this.isRetweet = false,
    this.isTweet = false,
  }) : super(key: key);

  @override
  _ComposeTweetPageState createState() => _ComposeTweetPageState();
}

class _ComposeTweetPageState extends State<ComposeTweetPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;
  int _characterCount = 0;
  String? _selectedGifUrl;
  static const int maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _characterCount = _textController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isRetweet ? 'Retweet' : 'Tweet',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _canPost() ? _postTweet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // User info and text input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      CircularImage(
                        path: context.read<AuthState>().userModel?.profilePic,
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.read<AuthState>().userModel?.displayName ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              context.read<AuthState>().userModel?.userName ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Text input
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: false,
                          decoration: const InputDecoration(
                            hintText: "What's happening?",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        
                        // Selected GIF preview
                        if (_selectedGifUrl != null)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _selectedGifUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedGifUrl = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Character count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$_characterCount',
                        style: TextStyle(
                          fontSize: 14,
                          color: _characterCount > maxCharacters
                              ? Colors.red
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Media button
                    IconButton(
                      icon: const Icon(Icons.image_outlined, color: AppTheme.primaryColor),
                      onPressed: _addMedia,
                    ),
                    
                    // Poll button
                    IconButton(
                      icon: const Icon(Icons.poll_outlined, color: AppTheme.primaryColor),
                      onPressed: _createPoll,
                    ),
                    
                    // GIF button
                    IconButton(
                      icon: const Icon(Icons.gif_outlined, color: AppTheme.primaryColor),
                      onPressed: _addGif,
                    ),
                    
                    // Emoji button
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined, color: AppTheme.primaryColor),
                      onPressed: _addEmoji,
                    ),
                  ],
                ),
                
                // Post button
                ElevatedButton(
                  onPressed: _canPost() ? _postTweet : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canPost() {
    return !_isPosting &&
           _characterCount <= maxCharacters &&
           _characterCount > 0;
  }

  Future<void> _postTweet() async {
    if (!_canPost()) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final feedState = context.read<FeedState>();
      final authState = context.read<AuthState>();
      
      // TODO: Implement actual tweet posting logic
      // For now, just show success message
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tweet posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  void _addMedia() {
    // TODO: Implement media selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Media selection coming soon!')),
    );
  }

  void _createPoll() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComposePollPage(),
      ),
    );
  }

  void _addGif() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GifPickerBottomSheet(
        onGifSelected: (gif) {
          setState(() {
            _selectedGifUrl = gif.displayUrl;
          });
        },
      ),
    );
  }

  void _addEmoji() {
    // TODO: Implement emoji picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emoji picker coming soon!')),
    );
  }
}
