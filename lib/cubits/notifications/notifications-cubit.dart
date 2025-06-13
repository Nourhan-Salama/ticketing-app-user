import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/cubits/notifications/notifications-state.dart';
import 'package:final_app/models/notifications-model.dart';
import 'package:final_app/services/notifications-services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationService _service;
   
  NotificationsCubit(this._service) : super(NotificationsInitial());

  List<NotificationModel> _technicianNotifications = [];

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final notifications = await _service.getAllNotifications();
      final unreadCount = await _service.getUnreadCount();

      _technicianNotifications = notifications.where((n) =>
        n.data.type == NotificationType.ticketResolved || 
        n.data.type == NotificationType.chat
      ).toList();

      if (unreadCount > 0) {
        await _service.playNotificationSound();
      }

      emit(NotificationsLoaded(notifications, unreadCount));
    } catch (e) {
      if (e.toString().contains('401')) {
        try {
          await _service.handleTokenRefresh();
          await loadNotifications();
        } catch (refreshError) {
          emit(NotificationsError('Session expired. Please login again.'.tr()));
        }
      } else {
        emit(NotificationsError('${'Failed to load notifications:'.tr()} ${e.toString()}'));
      }
    }
  }

  List<NotificationModel> get technicianNotifications => _technicianNotifications;

  Future<void> markAsRead(String notificationId) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final notificationIndex = currentState.notifications.indexWhere(
        (n) => n.id == notificationId,
      );

      if (notificationIndex == -1) return;

      final notification = currentState.notifications[notificationIndex];
      
      // Don't make API call if notification is already seen or read
      if (notification.read || notification.seen) {
        return;
      }

      try {
        // Optimistic update - mark as both read and seen
        final updatedNotification = notification.copyWith(
          read: true,
          seen: true,
        );
        
        final updatedNotifications = [...currentState.notifications];
        updatedNotifications[notificationIndex] = updatedNotification;
        
        // Update technician notifications list as well
        final techIndex = _technicianNotifications.indexWhere((n) => n.id == notificationId);
        if (techIndex != -1) {
          _technicianNotifications = [..._technicianNotifications];
          _technicianNotifications[techIndex] = updatedNotification;
        }
        
        final updatedUnreadCount = (currentState.unreadCount - 1).clamp(0, double.infinity).toInt();

        // Emit updated state immediately for instant UI feedback
        emit(NotificationsLoaded(updatedNotifications, updatedUnreadCount));

        // Then make API call
        await _service.markAsRead(notificationId);
        
      } catch (e) {
        // Revert state on error
        emit(NotificationsLoaded(currentState.notifications, currentState.unreadCount));
        
        // Revert technician notifications as well
        final originalNotifications = await _service.getAllNotifications();
        _technicianNotifications = originalNotifications.where((n) =>
          n.data.type == NotificationType.ticketResolved || 
          n.data.type == NotificationType.chat
        ).toList();
        
        emit(NotificationsError('${'Failed to mark as read:'.tr()} ${e.toString()}'));
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      // Get notifications that are not read and not seen (to avoid unnecessary API calls)
      final unreadNotifications = currentState.notifications.where((n) => !n.read && !n.seen).toList();
      
      if (unreadNotifications.isEmpty) {
        return; // No unread notifications to mark
      }
      
      try {
        // Optimistic update - mark all as read and seen
        final updatedNotifications = currentState.notifications.map((n) {
          return n.copyWith(
            read: true,
            seen: true,
          );
        }).toList();
        
        // Update technician notifications
        _technicianNotifications = _technicianNotifications.map((n) {
          return n.copyWith(
            read: true,
            seen: true,
          );
        }).toList();
        
        // Emit updated state immediately
        emit(NotificationsLoaded(updatedNotifications, 0));
        
        // Then make API call
        await _service.markAllAsRead();
        
      } catch (e) {
        // Revert state on error
        emit(NotificationsLoaded(currentState.notifications, currentState.unreadCount));
        
        // Revert technician notifications as well
        final originalNotifications = await _service.getAllNotifications();
        _technicianNotifications = originalNotifications.where((n) =>
          n.data.type == NotificationType.ticketResolved || 
          n.data.type == NotificationType.chat
        ).toList();
        
        emit(NotificationsError('${'Failed to mark all as read:'.tr()} ${e.toString()}'));
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      try {
        // Optimistic update - remove from lists immediately
        final updatedNotifications = currentState.notifications.where((n) => n.id != id).toList();
        _technicianNotifications = _technicianNotifications.where((n) => n.id != id).toList();
        
        // Calculate new unread count
        final deletedNotification = currentState.notifications.firstWhere((n) => n.id == id);
        final newUnreadCount = (!deletedNotification.read && !deletedNotification.seen) 
            ? (currentState.unreadCount - 1).clamp(0, double.infinity).toInt()
            : currentState.unreadCount;
        
        emit(NotificationsLoaded(updatedNotifications, newUnreadCount));
        
        // Then make API call
        await _service.deleteNotification(id);
        
      } catch (e) {
        // Revert and reload on error
        await loadNotifications();
        emit(NotificationsError('${'Failed to delete notification:'.tr()} ${e.toString()}'));
      }
    }
  }

  Future<void> deleteAll() async {
    if (state is NotificationsLoaded) {
      try {
        // Optimistic update - clear all notifications
        _technicianNotifications = [];
        emit(NotificationsLoaded([], 0));
        
        // Then make API call
        await _service.deleteAllNotifications();
        
      } catch (e) {
        // Reload on error
        await loadNotifications();
        emit(NotificationsError('${'Failed to delete all notifications:'.tr()} ${e.toString()}'));
      }
    }
  }
}