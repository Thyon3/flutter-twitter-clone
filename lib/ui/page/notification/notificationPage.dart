import 'package:flutter/material.dart';
import 'package:twitterclone/helper/enum.dart';
import 'package:twitterclone/model/feedModel.dart';
import 'package:twitterclone/model/notificationModel.dart';
import 'package:twitterclone/state/authState.dart';
import 'package:twitterclone/state/notificationState.dart';
import 'package:twitterclone/ui/page/notification/widget/follow_notification_tile.dart';
import 'package:twitterclone/ui/page/notification/widget/post_like_tile.dart';
import 'package:twitterclone/ui/theme/theme.dart';
import 'package:twitterclone/widgets/customAppBar.dart';
import 'package:twitterclone/widgets/customWidgets.dart';
import 'package:twitterclone/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key, required this.scaffoldKey})
      : super(key: key);

  /// scaffoldKey used to open sidebar drawer
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);
      var authState = Provider.of<AuthState>(context, listen: false);
      state.getDataFromDatabase(authState.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/NotificationPage');
  }

  void _showFilterOptions() {
    final notificationState = Provider.of<NotificationState>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...NotificationFilter.values.map((filter) => ListTile(
              title: Text(filter.displayName),
              trailing: notificationState.currentFilter == filter
                  ? const Icon(Icons.check, color: AppColor.primary)
                  : null,
              onTap: () {
                notificationState.setFilter(filter);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final notificationState = Provider.of<NotificationState>(context, listen: false);
    await notificationState.markAllAsRead();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    final notificationState = Provider.of<NotificationState>(context, listen: false);
    await notificationState.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText('Notifications'),
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
        actions: [
          Consumer<NotificationState>(
            builder: (context, notificationState, _) {
              return Row(
                children: [
                  if (notificationState.hasUnreadNotifications)
                    IconButton(
                      icon: const Icon(Icons.done_all),
                      onPressed: _markAllAsRead,
                      tooltip: 'Mark all as read',
                    ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilterOptions,
                    tooltip: 'Filter notifications',
                  ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              child: Consumer<NotificationState>(
                builder: (context, state, _) {
                  return state.unreadCount > 0
                      ? Badge(
                          label: Text(state.unreadCount.toString()),
                          child: const Tab(text: 'All'),
                        )
                      : const Tab(text: 'All');
                },
              ),
            ),
            const Tab(text: 'Pinned'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NotificationPageBody(
            scaffoldKey: widget.scaffoldKey,
            onRefresh: _refreshNotifications,
          ),
          PinnedNotificationsBody(
            scaffoldKey: widget.scaffoldKey,
          ),
        ],
      ),
    );
  }
}

class NotificationPageBody extends StatefulWidget {
  const NotificationPageBody({
    Key? key,
    required this.scaffoldKey,
    required this.onRefresh,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final Future<void> Function() onRefresh;

  @override
  _NotificationPageBodyState createState() => _NotificationPageBodyState();
}

class _NotificationPageBodyState extends State<NotificationPageBody> {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<NotificationState>(context);
    
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    var list = state.notificationList;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No notifications available yet',
          subTitle: 'When new notifications are found, they\'ll show up here.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        itemBuilder: (context, index) => _notificationRow(context, list[index]),
        itemCount: list.length,
      ),
    );
  }

  Widget _notificationRow(BuildContext context, NotificationModel model) {
    var state = Provider.of<NotificationState>(context);
    
    return Container(
      color: model.isRead ? Colors.white : Colors.blue.shade50,
      child: Column(
        children: [
          Dismissible(
            key: Key(model.id!),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              state.deleteNotification(model.id!);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: model.senderUser?.profileImage != null
                    ? NetworkImage(model.senderUser!.profileImage!)
                    : null,
                child: model.senderUser?.profileImage == null
                    ? Text(
                        model.senderUser?.displayName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                model.title,
                style: TextStyle(
                  fontWeight: model.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.getTimeAgo(),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!model.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            const Icon(Icons.done),
                            const SizedBox(width: 8),
                            Text(model.isRead ? 'Mark as unread' : 'Mark as read'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(model.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                            const SizedBox(width: 8),
                            Text(model.isPinned ? 'Unpin' : 'Pin'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          state.markAsRead(model.id!);
                          break;
                        case 'pin':
                          state.togglePin(model.id!);
                          break;
                        case 'delete':
                          state.deleteNotification(model.id!);
                          break;
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                // Mark as read when tapped
                if (!model.isRead) {
                  state.markAsRead(model.id!);
                }
                
                // Navigate to relevant content
                if (model.tweetKey != null) {
                  // Navigate to tweet detail
                  Navigator.pushNamed(context, '/FeedPostDetail/${model.tweetKey}');
                } else if (model.senderId != null) {
                  // Navigate to user profile
                  Navigator.pushNamed(context, '/ProfilePage/${model.senderId}');
                }
              },
            ),
          ),
          if (model.tweet != null)
            Container(
              margin: const EdgeInsets.only(left: 72, right: 16, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                model.tweet!.description ?? '',
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class PinnedNotificationsBody extends StatelessWidget {
  const PinnedNotificationsBody({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<NotificationState>(context);
    var pinnedNotifications = state.pinnedNotifications;

    if (pinnedNotifications.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No pinned notifications',
          subTitle: 'Pin important notifications to see them here.',
        ),
      );
    }

    return ListView.builder(
      itemCount: pinnedNotifications.length,
      itemBuilder: (context, index) {
        final model = pinnedNotifications[index];
        return Container(
          color: Colors.amber.shade50,
          child: ListTile(
            leading: const Icon(Icons.push_pin, color: Colors.amber),
            title: Text(model.title),
            subtitle: Text(model.getTimeAgo()),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                state.togglePin(model.id!);
              },
            ),
            onTap: () {
              if (model.tweetKey != null) {
                Navigator.pushNamed(context, '/FeedPostDetail/${model.tweetKey}');
              } else if (model.senderId != null) {
                Navigator.pushNamed(context, '/ProfilePage/${model.senderId}');
              }
            },
          ),
        );
      },
    );
  }
}
