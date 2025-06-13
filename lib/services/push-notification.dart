// notification_handler.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:final_app/services/notifications-services.dart';
import 'package:final_app/models/notifications-model.dart';
import 'package:final_app/screens/ticket-details.dart';
import 'package:final_app/cubits/tickets/get-ticket-cubits.dart';

class NotificationHandler {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  static final NotificationService _notificationService = NotificationService();
  
  // Global navigation key to handle navigation from anywhere
  static GlobalKey<NavigatorState>? navigatorKey;
  
  // Track processed notifications to avoid duplicates
  static final Set<String> _processedNotifications = <String>{};
  
  // Callbacks for different actions
  static Function()? onNotificationReceived;
  static Function(NotificationModel)? onNotificationOpened;

  /// Initialize the complete notification system
  static Future<void> initialize({
    required GlobalKey<NavigatorState> navigationKey,
    Function()? onReceived,
    Function(NotificationModel)? onOpened,
  }) async {
    try {
      navigatorKey = navigationKey;
      onNotificationReceived = onReceived;
      onNotificationOpened = onOpened;
      
      // Request permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get and update FCM token
      await _updateFcmToken();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Handle notification that opened the app
      await _handleInitialMessage();
      
      debugPrint('✅ Push notification system initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing push notification system: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📱 Notification permission: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
  }

  /// Handle local notification tap
  static void _onLocalNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final notificationData = json.decode(response.payload!);
        final notification = NotificationModel.fromJson(notificationData);
        _handleNotificationNavigation(notification);
      }
    } catch (e) {
      debugPrint('❌ Error handling local notification tap: $e');
    }
  }

  /// Update FCM token
  static Future<void> _updateFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _notificationService.updateFcmToken(token);
        debugPrint('🔑 FCM Token updated successfully');
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) async {
      try {
        await _notificationService.updateFcmToken(token);
        debugPrint('🔄 FCM Token refreshed successfully');
      } catch (e) {
        debugPrint('❌ Error refreshing FCM token: $e');
      }
    });
  }

  /// Setup message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// Handle foreground messages (app is open and visible)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📱 Received foreground message: ${message.messageId}');
    
    if (_isMessageProcessed(message.messageId)) return;
    _markMessageAsProcessed(message.messageId);

    try {
      // Play notification sound
      await _notificationService.playNotificationSound();
      
      // Show local notification
      await _showLocalNotification(message);
      
      // Trigger callback if provided
      onNotificationReceived?.call();
      
    } catch (e) {
      debugPrint('❌ Error handling foreground message: $e');
    }
  }

  /// Handle background messages (app is in background but not killed)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('📱 Received background message: ${message.messageId}');
    
    if (_isMessageProcessed(message.messageId)) return;
    _markMessageAsProcessed(message.messageId);

    try {
      final notification = _createNotificationFromMessage(message);
      _handleNotificationNavigation(notification);
    } catch (e) {
      debugPrint('❌ Error handling background message: $e');
    }
  }

  /// Handle initial message (app was terminated and opened by notification)
  static Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📱 Received initial message: ${initialMessage.messageId}');
        
        if (!_isMessageProcessed(initialMessage.messageId)) {
          _markMessageAsProcessed(initialMessage.messageId);
          
          final notification = _createNotificationFromMessage(initialMessage);
          
          // Delay navigation to ensure app is fully loaded
          Future.delayed(const Duration(seconds: 1), () {
            _handleNotificationNavigation(notification);
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling initial message: $e');
    }
  }

  /// Show local notification when app is in foreground
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'ticket_notifications',
        'Ticket Notifications',
        channelDescription: 'Notifications for ticket updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notification = _createNotificationFromMessage(message);
      
      await _localNotifications.show(
        notification.id.hashCode,
        message.notification?.title ?? notification.title,
        message.notification?.body ?? notification.body,
        notificationDetails,
        payload: json.encode(notification.toJson()),
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Create notification model from Firebase message
  static NotificationModel _createNotificationFromMessage(RemoteMessage message) {
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? 'New Notification',
      body: message.notification?.body ?? message.data['body'] ?? '',
      createdAt: DateTime.now(),
      seen: false,
      read: false,
      data: NotificationData(
        type: NotificationType.fromString(message.data['type'] ?? 'unknown'),
        modelId: int.tryParse(message.data['model_id'] ?? '0') ?? 0,
      ),
    );
  }

  /// Handle navigation based on notification type
  static Future<void> _handleNotificationNavigation(NotificationModel notification) async {
    try {
      // Trigger callback if provided
      onNotificationOpened?.call(notification);
      
      // Handle ticket-related notifications
      if (_isTicketNotification(notification.data.type)) {
        await _navigateToTicketDetails(notification);
      } else {
        // Handle other notification types
        _navigateToNotificationsScreen();
      }
    } catch (e) {
      debugPrint('❌ Error handling notification navigation: $e');
    }
  }

  /// Navigate to ticket details screen
  static Future<void> _navigateToTicketDetails(NotificationModel notification) async {
    final context = navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('❌ Navigation context not available');
      return;
    }

    final ticketId = notification.data.modelId;
    if (ticketId <= 0) {
      debugPrint('❌ Invalid ticket ID: $ticketId');
      _showError(context, 'Invalid ticket ID');
      return;
    }

    try {
      // Show loading dialog
      _showLoadingDialog(context);

      // Get ticket details
      final ticketsCubit = context.read<TicketsCubit>();
      final ticketDetails = await ticketsCubit.getTicketDetails(ticketId);
      final fullTicket = await ticketsCubit.getTicketById(ticketId);

      // Hide loading dialog
      Navigator.of(context).pop();

      // Navigate to ticket details
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TicketDetailsScreen(
            ticket: ticketDetails,
            userTicket: fullTicket,
          ),
        ),
      );
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
      _showError(context, 'Failed to load ticket: ${e.toString()}');
    }
  }

  /// Navigate to notifications screen
  static void _navigateToNotificationsScreen() {
    final context = navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed('/notifications');
    }
  }

  /// Show loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Show error message
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Check if notification is ticket-related
  static bool _isTicketNotification(NotificationType type) {
    return [
      NotificationType.ticketCreated,
      NotificationType.ticketUpdated,
      NotificationType.ticketAssigned,
      NotificationType.ticketResolved,
      NotificationType.chat,
    ].contains(type);
  }

  /// Message processing helpers
  static bool _isMessageProcessed(String? messageId) {
    return messageId != null && _processedNotifications.contains(messageId);
  }

  static void _markMessageAsProcessed(String? messageId) {
    if (messageId != null) {
      _processedNotifications.add(messageId);
    }
  }

  /// Clear processed messages cache (call periodically to prevent memory leaks)
  static void clearProcessedMessages() {
    _processedNotifications.clear();
  }

  /// Get FCM token for testing
  static Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }
}