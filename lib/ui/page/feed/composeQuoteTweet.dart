import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/quoteTweetModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/quoteTweetState.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customWidgets.dart';
import 'package:twitterclone/widgets/tweet/quote_tweet_widget.dart';

class ComposeQuoteTweetPage extends StatefulWidget {
  final FeedModel quotedTweet;

  const ComposeQuoteTweetPage({
    Key? key,
    required this.quotedTweet,
  }) : super(key: key);

  @override
  _ComposeQuoteTweetPageState createState() => _ComposeQuoteTweetPageState();
}

class _ComposeQuoteTweetPageState extends State<ComposeQuoteTweetPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isPosting = false;
  int _characterCount = 0;
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
        title: const Text(
          'Quote Tweet',
          style: TextStyle(
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
              onPressed: _canPost() ? _postQuoteTweet : null,
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
                      'Quote',
                      style: TextStyle(fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quoted tweet preview
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _buildQuotedTweetPreview(),
          ),
          
          // Quote tweet input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
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
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedTweetPreview() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quoted tweet author info
          Row(
            children: [
              CircularImage(
                path: widget.quotedTweet.user?.profilePic,
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.quotedTweet.user?.displayName ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                widget.quotedTweet.user?.userName ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          
          // Quoted tweet content
          if (widget.quotedTweet.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.quotedTweet.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Quoted tweet image preview
          if (widget.quotedTweet.imagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.quotedTweet.imagePath!,
                  height: 60,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 24,
                      ),
                    );
                  },
                ),
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

  Future<void> _postQuoteTweet() async {
    if (!_canPost()) return;

    setState(() {
      _isPosting = true;
    });

    try {
      final quoteTweetState = context.read<QuoteTweetState>();
      final success = await quoteTweetState.createQuoteTweet(
        quotedTweetKey: widget.quotedTweet.key!,
        description: _textController.text.trim(),
      );

      if (success != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote tweet posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post quote tweet'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
}
