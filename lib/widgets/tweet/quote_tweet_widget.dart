import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/quoteTweetModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/ui/page/feed/feedPostDetail.dart';
import 'package:twitterclone/ui/page/profile/profilePage.dart';
import 'package:twitterclone/ui/page/profile/widgets/circular_image.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/newWidget/title_text.dart';
import 'package:twitterclone/widgets/tweet/widgets/tweet.dart';
import 'package:twitterclone/widgets/url_text/customUrlText.dart';
import 'package:twitterclone/widgets/customWidgets.dart';

class QuoteTweetWidget extends StatelessWidget {
  final QuoteTweetModel quoteTweet;
  final TweetType type;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const QuoteTweetWidget({
    Key? key,
    required this.quoteTweet,
    this.type = TweetType.Tweet,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!quoteTweet.isValidQuoteTweet) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote tweet header with author info
          _buildQuoteHeader(context),
          
          // Quote tweet content
          if (quoteTweet.description != null && quoteTweet.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: UrlText(
                text: quoteTweet.description!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                urlStyle: const TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          
          // Quoted tweet preview
          if (quoteTweet.quotedTweet != null)
            _buildQuotedTweetPreview(context),
          
          // Quote tweet media
          if (quoteTweet.imagePath != null)
            _buildQuoteMedia(context),
          
          // Quote tweet actions
          _buildQuoteActions(context),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuoteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                ProfilePage.getRoute(profileId: quoteTweet.userId),
              );
            },
            child: CircularImage(
              path: quoteTweet.user?.profilePic,
              height: 40,
              width: 40,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TitleText(
                      quoteTweet.user?.displayName ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    if (quoteTweet.user?.isVerified == true)
                      customIcon(
                        context,
                        icon: AppIcon.blueTick,
                        isTwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3,
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      quoteTweet.user?.userName ?? '',
                      style: TextStyles.userNameStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '· ${_getTimeAgo(quoteTweet.createdAt)}',
                      style: TextStyles.userNameStyle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            onPressed: () => _showQuoteOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotedTweetPreview(BuildContext context) {
    final quotedTweet = quoteTweet.quotedTweet!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(
              context,
              FeedPostDetail.getRoute(quotedTweet.key!),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quoted tweet author info
                Row(
                  children: [
                    CircularImage(
                      path: quotedTweet.user?.profilePic,
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quotedTweet.user?.displayName ?? '',
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
                      quotedTweet.user?.userName ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                
                // Quoted tweet content
                if (quotedTweet.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      quotedTweet.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                // Quoted tweet image preview
                if (quotedTweet.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        quotedTweet.imagePath!,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteMedia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          quoteTweet.imagePath!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuoteActions(BuildContext context) {
    final authState = context.watch<AuthState>();
    final isLiked = quoteTweet.isLikedByUser(authState.userModel?.userId ?? '');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            icon: Icons.comment_outlined,
            count: quoteTweet.commentCount,
            onTap: () {
              Navigator.push(
                context,
                FeedPostDetail.getRoute(quoteTweet.key!),
              );
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.repeat,
            count: quoteTweet.retweetCount,
            onTap: () {
              // TODO: Implement retweet functionality
            },
          ),
          _buildActionButton(
            context,
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: quoteTweet.likeCount,
            isActive: isLiked,
            activeColor: Colors.red,
            onTap: () {
              // TODO: Implement like functionality
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.share,
            count: null,
            onTap: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    int? count,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor ?? AppTheme.primaryColor : Colors.grey.shade600,
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? activeColor ?? AppTheme.primaryColor : Colors.grey.shade600,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQuoteOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'Quote Tweet Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share quote tweet'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy link'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement copy link functionality
            },
          ),
          if (quoteTweet.userId == context.read<AuthState>().userModel?.userId)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete quote tweet', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
              },
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(String createdAt) {
    // TODO: Implement proper time ago calculation
    // For now, return a placeholder
    return 'now';
  }
}
