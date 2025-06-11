import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:final_app/models/message-model.dart';

class PusherService {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _isInitialized = false;
  static String? _userId;
  static String? _currentConversationChannel;
  static String? _currentUserChannel;

  // Callbacks for different events
  static Function(MessageModel)? onNewMessage;
  static Function(String)? onMessageDeleted;
  static Function()? onConversationUpdated;

  /// Initialize Pusher service once when app starts
  static Future<void> initPusher({required String userId}) async {
    if (_isInitialized) return;
    
    _userId = userId;

    try {
      await _pusher.init(
        apiKey: '4924e59671f5cabb61cb',
        cluster: 'eu',
        onEvent: _handlePusherEvent,
        onError: (message, code, error) {
          print("Pusher error: $message, Code: $code, Exception: $error");
        },
      );

      await _pusher.connect();
      _isInitialized = true;
      print("Pusher initialized successfully for user: $userId");

      // Subscribe to user's personal channel for conversation updates
      await _subscribeToUserChannel();
      
    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  /// Subscribe to user's personal channel for conversation updates
  static Future<void> _subscribeToUserChannel() async {
    if (!_isInitialized || _userId == null) return;

    try {
      _currentUserChannel = 'chat.$_userId';
      await _pusher.subscribe(channelName: _currentUserChannel!);
      print("Subscribed to user channel: $_currentUserChannel");
    } catch (e) {
      print("Error subscribing to user channel: $e");
    }
  }

  /// Subscribe to a specific conversation for real-time messages
  static Future<void> subscribeToConversation(String conversationId) async {
    if (!_isInitialized) {
      print("Pusher not initialized");
      return;
    }

    try {
      final newConversationChannel = 'conversations.$conversationId';

      // Unsubscribe from previous conversation if different
      if (_currentConversationChannel != null && 
          _currentConversationChannel != newConversationChannel) {
        await unsubscribeFromConversation();
      }

      await _pusher.subscribe(channelName: newConversationChannel);
      _currentConversationChannel = newConversationChannel;
      print("Subscribed to conversation: $newConversationChannel");
      
    } catch (e) {
      print("Error subscribing to conversation: $e");
    }
  }

  /// Unsubscribe from current conversation
  static Future<void> unsubscribeFromConversation() async {
    if (_currentConversationChannel != null) {
      try {
        await _pusher.unsubscribe(channelName: _currentConversationChannel!);
        print("Unsubscribed from conversation: $_currentConversationChannel");
        _currentConversationChannel = null;
      } catch (e) {
        print("Error unsubscribing from conversation: $e");
      }
    }
  }

  /// Handle all Pusher events
  static void _handlePusherEvent(PusherEvent event) {
    print("Pusher event received - Channel: ${event.channelName}, Event: ${event.eventName}");
    print("Event data: ${event.data}");

    try {
      switch (event.eventName) {
        case 'new-message':
          _handleNewMessage(event.data);
          break;
        case 'message-deleted':
          _handleMessageDeleted(event.data);
          break;
        case 'conversation-updated':
          _handleConversationUpdated(event.data);
          break;
        default:
          print("Unknown event: ${event.eventName}");
      }
    } catch (e) {
      print("Error handling Pusher event: $e");
    }
  }

  /// Handle new message event
  static void _handleNewMessage(String data) {
    try {
      final jsonData = jsonDecode(data);
      final message = MessageModel.fromJson(jsonData);
      print("New message received: ${message.content}");
      onNewMessage?.call(message);
    } catch (e) {
      print("Error parsing new message: $e");
    }
  }

  /// Handle message deleted event
  static void _handleMessageDeleted(String data) {
    try {
      final jsonData = jsonDecode(data);
      final messageId = jsonData['message_id']?.toString();
      if (messageId != null) {
        print("Message deleted: $messageId");
        onMessageDeleted?.call(messageId);
      }
    } catch (e) {
      print("Error parsing deleted message: $e");
    }
  }

  /// Handle conversation updated event
  static void _handleConversationUpdated(String data) {
    try {
      print("Conversation updated");
      onConversationUpdated?.call();
    } catch (e) {
      print("Error handling conversation update: $e");
    }
  }

  /// Set callback for new messages
  static void setOnNewMessageCallback(Function(MessageModel) callback) {
    onNewMessage = callback;
  }

  /// Set callback for deleted messages
  static void setOnMessageDeletedCallback(Function(String) callback) {
    onMessageDeleted = callback;
  }

  /// Set callback for conversation updates
  static void setOnConversationUpdatedCallback(Function() callback) {
    onConversationUpdated = callback;
  }

  /// Clear all callbacks
  static void clearCallbacks() {
    onNewMessage = null;
    onMessageDeleted = null;
    onConversationUpdated = null;
  }

  /// Disconnect and cleanup
  static Future<void> disconnect() async {
    try {
      await unsubscribeFromConversation();
      if (_currentUserChannel != null) {
        await _pusher.unsubscribe(channelName: _currentUserChannel!);
        _currentUserChannel = null;
      }
      await _pusher.disconnect();
      _isInitialized = false;
      clearCallbacks();
      print("Pusher disconnected");
    } catch (e) {
      print("Error disconnecting Pusher: $e");
    }
  }

  /// Check if Pusher is connected
  static bool get isConnected => _isInitialized;

  /// Get current user ID
  static String? get currentUserId => _userId;
}
