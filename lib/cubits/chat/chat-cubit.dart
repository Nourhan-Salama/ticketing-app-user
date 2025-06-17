import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:final_app/cubits/chat/chat-state.dart';
import 'package:final_app/models/message-model.dart';
import 'package:final_app/services/chat-service.dart';
import 'package:final_app/services/pusher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatCubit extends Cubit<ChatState> {
  final MessageService _messageService;
  final String conversationId;
  final String currentUserId;
  final storage = const FlutterSecureStorage();

  ChatCubit({
    required MessageService messageService,
    required this.conversationId,
    required this.currentUserId,
  }) : _messageService = messageService,
        super(ChatInitial()) {
    _initializePusher();
  }

  /// Initialize Pusher and set up event listeners
  Future<void> _initializePusher() async {
    try {
      // Initialize Pusher service
      await PusherService.initPusher(userId: currentUserId);
      
      // Subscribe to this conversation
      await PusherService.subscribeToConversation(conversationId);
      
      // Set up event callbacks
      PusherService.setOnNewMessageCallback(_onNewMessage);
      PusherService.setOnMessageDeletedCallback(_onMessageDeleted);
      
      print("Pusher initialized for conversation: $conversationId");
    } catch (e) {
      print("Error initializing Pusher: $e");
    }
  }

  /// Handle new message from Pusher
  void _onNewMessage(MessageModel newMessage) {
    print("Pusher: New message received - ID: ${newMessage.id}, Content: ${newMessage.content}");
    
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Check if message already exists (to avoid duplicates)
      final messageExists = currentState.messages.any(
        (msg) => msg.id == newMessage.id
      );
      
      if (!messageExists) {
        final updatedMessages = List<MessageModel>.from(currentState.messages)
          ..add(newMessage);
        
        // Sort messages by timestamp to ensure correct order
        updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        emit(ChatLoaded(updatedMessages));
        print("New message added via Pusher: ${newMessage.content}");
      } else {
        print("Message already exists, skipping duplicate");
      }
    } else {
      print("State is not ChatLoaded, current state: ${state.runtimeType}");
    }
  }

  /// Handle message deletion from Pusher
  void _onMessageDeleted(String messageId) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = currentState.messages
          .where((msg) => msg.id.toString() != messageId)
          .toList();
      emit(ChatLoaded(updatedMessages));
      print("Message deleted via Pusher: $messageId");
    }
  }

  Future<void> loadMessages() async {
    emit(ChatLoading());
    try {
      final response = await _messageService.getMessages(conversationId);
      final messages = (response['data'] as List?)
              ?.map((json) => MessageModel.fromJson(json))
              .toList() ??
          [];
      
      // Sort messages by timestamp
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      emit(ChatLoaded(messages));
      print("Messages loaded: ${messages.length} messages");
    } catch (e) {
      print('LoadMessages error: $e');
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> sendTextMessage(String content) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Show sending state
      emit(ChatLoaded(currentState.messages, isSending: true));
      
      try {
        print("Sending text message: $content");
        final response = await _messageService.sendMessage(
          conversationId,
          type: 0,
          content: content,
        );
        
        print("Message sent successfully: $response");
        
        // If Pusher doesn't deliver the message quickly, add it manually as fallback
        await _addMessageWithFallback(response);
        
        // Reset sending state
        emit(ChatLoaded(state is ChatLoaded ? (state as ChatLoaded).messages : currentState.messages));
        
      } catch (e) {
        print('Send text message error: $e');
        emit(ChatLoaded(currentState.messages));
      }
    }
  }

  Future<void> sendMediaMessage(String mediaPath) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Show sending state
      emit(ChatLoaded(currentState.messages, isSending: true));
      
      try {
        print("Sending media message: $mediaPath");
        final response = await _messageService.sendMessage(
          conversationId,
          type: 1,
          mediaPath: mediaPath,
        );
        
        print("Media message sent successfully: $response");
        
        // If Pusher doesn't deliver the message quickly, add it manually as fallback
        await _addMessageWithFallback(response);
        
        // Reset sending state
        emit(ChatLoaded(state is ChatLoaded ? (state as ChatLoaded).messages : currentState.messages));
        
      } catch (e) {
        print('Send media message error: $e');
        emit(ChatLoaded(currentState.messages));
      }
    }
  }

  /// Fallback method to add message if Pusher doesn't deliver it quickly
  Future<void> _addMessageWithFallback(dynamic response) async {
    // Wait a short time for Pusher to deliver the message
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      
      // Check if the message was already added by Pusher
      if (response != null && response['data'] != null) {
        try {
          final newMessage = MessageModel.fromJson(response['data']);
          final messageExists = currentState.messages.any(
            (msg) => msg.id == newMessage.id
          );
          
          // If message doesn't exist, add it manually
          if (!messageExists) {
            print("Adding message manually as fallback");
            final updatedMessages = List<MessageModel>.from(currentState.messages)
              ..add(newMessage);
            
            // Sort messages by timestamp
            updatedMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            
            emit(ChatLoaded(updatedMessages));
          } else {
            print("Message already exists (likely added by Pusher)");
          }
        } catch (e) {
          print("Error parsing message response for fallback: $e");
        }
      }
    }
  }

  /// Refresh messages - useful for debugging
  Future<void> refreshMessages() async {
    await loadMessages();
  }

  @override
  Future<void> close() async {
    // Clean up Pusher when cubit is closed
    PusherService.clearCallbacks();
    await PusherService.unsubscribeFromConversation();
    return super.close();
  }
}
