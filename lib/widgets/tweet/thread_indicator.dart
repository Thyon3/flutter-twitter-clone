import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/state/threadState.dart';
import 'package:twitterclone/ui/theme/theme.dart';

class ThreadIndicator extends StatelessWidget {
  final FeedModel tweet;
  final VoidCallback? onTap;

  const ThreadIndicator({
    Key? key,
    required this.tweet,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!tweet.isPartOfThread) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.thread,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Thread',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (tweet.threadPositionText != null) ...[
              const SizedBox(width: 4),
              Text(
                '• ${tweet.threadPositionText}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor.withOpacity(0.8),
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 14,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class ThreadConnector extends StatelessWidget {
  final bool showTopLine;
  final bool showBottomLine;
  final Color? color;

  const ThreadConnector({
    Key? key,
    this.showTopLine = true,
    this.showBottomLine = true,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectorColor = color ?? Colors.grey.shade300;
    
    return Container(
      width: 2,
      child: Column(
        children: [
          if (showTopLine)
            Expanded(
              child: Container(
                color: connectorColor,
              ),
            ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: connectorColor,
              shape: BoxShape.circle,
            ),
          ),
          if (showBottomLine)
            Expanded(
              child: Container(
                color: connectorColor,
              ),
            ),
        ],
      ),
    );
  }
}

class ThreadSummaryWidget extends StatelessWidget {
  final FeedModel threadStarter;
  final int totalTweets;
  final VoidCallback onTap;

  const ThreadSummaryWidget({
    Key? key,
    required this.threadStarter,
    required this.totalTweets,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.thread,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thread',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalTweets tweets',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              threadStarter.description ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'View thread',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThreadActionButton extends StatelessWidget {
  final FeedModel tweet;
  final VoidCallback onAddToThread;

  const ThreadActionButton({
    Key? key,
    required this.tweet,
    required this.onAddToThread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final threadState = context.watch<ThreadState>();
    
    if (!tweet.isPartOfThread || tweet.isThreadLast) {
      return const SizedBox.shrink();
    }

    if (!threadState.canUserAddToCurrentThread(threadState.getCurrentUser)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        onPressed: onAddToThread,
        icon: const Icon(Icons.add, size: 16),
        label: const Text(
          'Add to thread',
          style: TextStyle(fontSize: 12),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
