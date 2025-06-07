import 'package:easy_localization/easy_localization.dart';
import 'package:final_app/cubits/notifications/notifications-state.dart';
import 'package:final_app/models/notifications-model.dart';
import 'package:final_app/services/notifications-services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationService _service;
  
  NotificationsCubit(this._service) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final notifications = await _service.getAllNotifications();
      final unreadCount = await _service.getUnreadCount();
      emit(NotificationsLoaded(notifications, unreadCount));
    } catch (e) {
      emit(NotificationsError('Failed to load notifications'.tr()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (state is! NotificationsLoaded) return;
    final currentState = state as NotificationsLoaded;

    try {
      await _service.markAsRead(notificationId);
      final updatedNotifications = currentState.notifications.map((n) {
        return n.id == notificationId ? n.copyWith(read: true, seen: true) : n;
      }).toList();

      final updatedUnreadCount = updatedNotifications.where((n) => !n.seen).length;
      emit(NotificationsLoaded(updatedNotifications, updatedUnreadCount));
    } catch (e) {
      emit(NotificationsError('Failed to mark as read'.tr()));
    }
  }

  Future<void> markAllAsRead() async {
    if (state is! NotificationsLoaded) return;
    
    try {
      await _service.markAllAsRead();
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = currentState.notifications.map((n) {
        return n.copyWith(read: true, seen: true);
      }).toList();

      emit(NotificationsLoaded(updatedNotifications, 0));
    } catch (e) {
      emit(NotificationsError('Failed to mark all as read'.tr()));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to delete notification'.tr()));
    }
  }

  Future<void> deleteAll() async {
    try {
      await _service.deleteAllNotifications();
      await loadNotifications();
    } catch (e) {
      emit(NotificationsError('Failed to delete all notifications'.tr()));
    }
  }
}
// import 'package:easy_localization/easy_localization.dart';
// import 'package:final_app/cubits/notifications/notifications-state.dart';
// import 'package:final_app/models/notifications-model.dart';
// import 'package:final_app/services/notifications-services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';


// class NotificationsCubit extends Cubit<NotificationsState> {
//   final NotificationService _service;
   
//   NotificationsCubit(this._service) : super(NotificationsInitial());

//   List<NotificationModel> _technicianNotifications = [];

//   Future<void> loadNotifications() async {
//     if (state is NotificationsLoaded) return;
//     emit(NotificationsLoading());
//     try {
//       final notifications = await _service.getAllNotifications();
//       final unreadCount = await _service.getUnreadCount();

//       _technicianNotifications = notifications.where((n) =>
//         n.data.type == NotificationType.ticketResolved|| 
//         n.data.type == NotificationType.chat
//       ).toList();

//       if (unreadCount > 0) {
//         await _service.playNotificationSound();
//       }

//       emit(NotificationsLoaded(notifications, unreadCount));
//     } catch (e) {
//       if (e.toString().contains('401')) {
//         try {
//           await _service.handleTokenRefresh();
//           await loadNotifications();
//         } catch (refreshError) {
//           emit(NotificationsError('Session expired. Please login again.'.tr()));
//         }
//       } else {
//         emit(NotificationsError('${'Failed to load notifications:'.tr()} ${e.toString()}'));

//       }
//     }
//   }

//   List<NotificationModel> get technicianNotifications => _technicianNotifications;

//   Future<void> markAsRead(String notificationId) async {
//     if (state is NotificationsLoaded) {
//       final currentState = state as NotificationsLoaded;

//       final notificationIndex = currentState.notifications.indexWhere(
//         (n) => n.id == notificationId,
//       );

//       if (notificationIndex == -1) return;

//       final notification = currentState.notifications[notificationIndex];
//       if (notification.seen) return;

//       try {
//         await _service.markAsRead(notificationId);

//         final updatedNotification = notification.copyWith(
//           read: true,
//           seen: true,
//         );
//         final updatedNotifications = [...currentState.notifications];
//         updatedNotifications[notificationIndex] = updatedNotification;

//         final updatedUnreadCount = currentState.unreadCount - 1;

//         emit(NotificationsLoaded(updatedNotifications, updatedUnreadCount));
//       } catch (e) {
//        emit(NotificationsError('${'Failed to mark as read:'.tr()} ${e.toString()}'));

//       }
//     }
//   }

//   Future<void> markAllAsRead() async {
//     if (state is NotificationsLoaded) {
//       final currentState = state as NotificationsLoaded;
      
//       try {
//         // Mark all as read in the backend
//         await _service.markAllAsRead();

//         // Update all notifications locally
//         final updatedNotifications = currentState.notifications.map((notification) {
//           return notification.copyWith(
//             read: true,
//             seen: true,
//           );
//         }).toList();

//         emit(NotificationsLoaded(updatedNotifications, 0));
//       } catch (e) {
//        emit(NotificationsError('${'Failed to mark all as read:'.tr()} ${e.toString()}'));
//       }
//     }
//   }

//   Future<void> deleteNotification(String id) async {
//     try {
//       await _service.deleteNotification(id);
//       await loadNotifications();
//     } catch (e) {
//       emit(NotificationsError('${'Failed to delete notification:'.tr()} ${e.toString()}'));

//     }
//   }

//   Future<void> deleteAll() async {
//     try {
//       await _service.deleteAllNotifications();
//       await loadNotifications();
//     } catch (e) {
//      emit(NotificationsError('${'Failed to delete all notifications:'.tr()} ${e.toString()}'));

//     }
//   }
// }

