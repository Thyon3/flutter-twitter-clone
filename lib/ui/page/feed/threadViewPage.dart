import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/threadState.dart';
import 'package:twitterclone/ui/page/common/usersListPage.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/tweet/thread_indicator.dart';
import 'package:twitterclone/widgets/tweet/widgets/tweet.dart';

class ThreadViewPage extends StatefulWidget {
  final String threadId;
  final FeedModel? initialTweet;

  const ThreadViewPage({
    Key? key,
    required this.threadId,
    this.initialTweet,
  }) : super(key: key);

  static Route getRoute(String threadId) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/ThreadViewPage'),
      builder: (context) => ThreadViewPage(threadId: threadId),
    );
  }

  @override
  _ThreadViewPageState createState() => _ThreadViewPageState();
}

class _ThreadViewPageState extends State<ThreadViewPage> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThreadState>().loadThread(widget.threadId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.extraLightGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.extraLightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<ThreadState>(
          builder: (context, threadState, _) {
            if (threadState.isLoadingThread) {
              return const Text('Thread...');
            }
            
            if (threadState.threadStarter != null) {
              return Text(
                'Thread by ${threadState.threadStarter!.user!.userName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              );
            }
            
            return const Text('Thread');
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<ThreadState>(
            builder: (context, threadState, _) {
              if (threadState.currentThread.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () => _showThreadOptions(context, threadState),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ThreadState>(
        builder: (context, threadState, _) {
          if (threadState.isLoadingThread) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (threadState.currentThread.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thread,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thread not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This thread may have been deleted',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: threadState.currentThread.length + 1, // +1 for add button
            itemBuilder: (context, index) {
              // Add to thread button
              if (index == threadState.currentThread.length) {
                return _buildAddToThreadButton(threadState);
              }

              final tweet = threadState.currentThread[index];
              final isLastTweet = index == threadState.currentThread.length - 1;
              
              return Column(
                children: [
                  _buildTweetWithConnector(tweet, isLastTweet),
                  if (!isLastTweet) const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTweetWithConnector(FeedModel tweet, bool isLastTweet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thread connector line
          if (!isLastTweet)
            ThreadConnector(
              showTopLine: tweet.threadPosition != 0,
              showBottomLine: true,
            )
          else
            ThreadConnector(
              showTopLine: tweet.threadPosition != 0,
              showBottomLine: false,
            ),
          const SizedBox(width: 12),
          
          // Tweet content
          Expanded(
            child: Tweet(
              tweet: tweet,
              isThreadView: true,
              showThreadIndicator: false, // We show custom thread info
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToThreadButton(ThreadState threadState) {
    final authState = context.read<AuthState>();
    
    if (!threadState.canUserAddToCurrentThread(authState.userModel)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: TextButton.icon(
        onPressed: () => _showAddToThreadDialog(threadState),
        icon: const Icon(Icons.add),
        label: const Text('Add to this thread'),
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  void _showThreadOptions(BuildContext context, ThreadState threadState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Thread Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share thread'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement thread sharing
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_link),
            title: const Text('Copy link to thread'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement copy link
            },
          ),
          if (threadState.threadStarter?.userId == context.read<AuthState>().userModel?.userId)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete thread', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteThreadDialog(threadState);
              },
            ),
        ],
      ),
    );
  }

  void _showAddToThreadDialog(ThreadState threadState) {
    // TODO: Navigate to compose tweet with thread context
    // For now, show a simple dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Thread'),
        content: const Text('This will add your tweet to the end of this thread.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to compose page with thread context
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showDeleteThreadDialog(ThreadState threadState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: const Text(
          'This will permanently delete the entire thread and all its tweets. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: Implement thread deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
