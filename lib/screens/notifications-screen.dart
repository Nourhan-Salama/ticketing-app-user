import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/cubits/notifications/notifications-cubit.dart';
import 'package:final_app/cubits/notifications/notifications-state.dart';
import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';
import 'package:final_app/models/notifications-model.dart';
import 'package:final_app/screens/ticket-details.dart';
import 'package:final_app/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  Future<void> _handleNotificationTap(
      BuildContext context, NotificationModel notification) async {
    // Always navigate regardless of read status
    if (notification.data.type == NotificationType.ticketResolved ||

        notification.data.type == NotificationType.chat ||
        notification.data.type == NotificationType.ticketAssigned ||
        notification.data.type == NotificationType.ticketUpdated) {
      await navigateToTicketDetails(context, notification);
    }

    // Only mark as read if not already read AND not already seen
    if (!notification.read && !notification.seen) {
      await context.read<NotificationsCubit>().markAsRead(notification.id);
    }
  }

  Future<void> navigateToTicketDetails(
      BuildContext context, NotificationModel notification) async {
    final ticketId = notification.data.modelId;
    if (ticketId == 0) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ticketDetails =
          await context.read<TicketsCubit>().getTicketDetails(ticketId);
      final fullTicket = await context.read<TicketsCubit>().getTicketById(ticketId);

      if (!mounted) return;
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(
            ticket: ticketDetails,
            userTicket: fullTicket,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load ticket: ${e.toString()}')),
      );
    }
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    // Use read status for UI changes (read implies seen)
    final isRead = notification.read || notification.seen;
    
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: ColorsHelper.LightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('delete_notification_confirm_title'.tr()),
            content:  Text('delete_notification_confirm_message'.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('delete'.tr(), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<NotificationsCubit>().deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('delete_notification_success'.tr())),
        );
      },
      child: Card(
        // Use isRead for consistent UI
        color: isRead ? Colors.grey[200] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isRead 
                ? Colors.grey[300]!
                : Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: isRead ? 1 : 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(context, notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getNotificationIcon(notification.data.type),
                      color: isRead
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: isRead 
                              ? FontWeight.normal 
                              : FontWeight.bold,
                          color: isRead ? Colors.grey[700] : Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(notification.createdAt),
                      style: TextStyle(
                        color: isRead 
                            ? Colors.grey[600] 
                            : Theme.of(context).primaryColor,
                        fontSize: 12,
                      ),
                    ),
                    // Show dot only if notification is not read AND not seen
                    if (!notification.read && !notification.seen) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: isRead ? Colors.grey[600] : Colors.grey[800],
                  ),
                ),
                if (notification.data.type != NotificationType.unknown) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      notification.data.type.displayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isRead ? Colors.grey : Colors.white,
                      ),
                    ),
                    backgroundColor: isRead 
                        ? Colors.grey[300] 
                        : Theme.of(context).primaryColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.ticketCreated:
        return Icons.add_alert;
      case NotificationType.ticketUpdated:
        return Icons.edit;
      case NotificationType.ticketAssigned:
        return Icons.assignment_ind;
      case NotificationType.ticketResolved:
        return Icons.check_circle;
      case NotificationType.chat:
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  void _markAllAsRead(BuildContext context) {
    context.read<NotificationsCubit>().markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text('all_notifications_marked_read'.tr())),
    );
  }

  void _deleteAllNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_all_confirm_title'.tr()),
        content:  Text('delete_all_confirm_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationsCubit>().deleteAll();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('all_notifications_deleted'.tr())),
              );
            },
            child: Text('delete_all'.tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('notifications_title'.tr()),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final isLoading = state is NotificationsLoading;
              final hasUnreadNotifications = state is NotificationsLoaded && state.unreadCount > 0;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnreadNotifications)
                    Badge(
                      label: Text((state).unreadCount.toString()),
                      child: IconButton(
                        icon: const Icon(Icons.mark_as_unread),
                        onPressed: isLoading ? null : () => _markAllAsRead(context),
                        tooltip: 'mark_all_read'.tr(),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.mark_as_unread),
                      onPressed: isLoading ? null : () => _markAllAsRead(context),
                      tooltip: 'mark_all_read'.tr(),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: isLoading ? null : () => _deleteAllNotifications(context),
                    tooltip: 'delete_all'.tr(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<NotificationsCubit>().loadNotifications(),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final notifications = context.read<NotificationsCubit>().technicianNotifications;

          if (notifications.isEmpty) {
            return Center(child: Text('no_notifications'.tr()));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().loadNotifications(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, notification);
              },
            ),
          );
        },
      ),
    );
  }
}
