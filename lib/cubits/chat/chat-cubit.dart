import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:final_app/cubits/chat/chat-state.dart';
import 'package:final_app/models/message-model.dart';
import 'package:final_app/services/chat-service.dart';
import 'package:flutter/material.dart';
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
  })  : _messageService = messageService,
        super(ChatInitial());

  Future<void> loadMessages() async {
    emit(ChatLoading());
    try {
      final response = await _messageService.getMessages(conversationId);
      final messages = (response['data'] as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  Future<void> sendTextMessage(String content) async {
    emit(MessageSending());
    try {
      final response = await _messageService.sendMessage(
        conversationId,
        type: 0,
        content: content,
      );
      final newMessage = MessageModel.fromJson(response['data']);
      emit(MessageSent(newMessage));
      _updateMessagesAfterSend(newMessage);
    } catch (e) {
      emit(MessageSendError('Failed to send message: $e'));
    }
  }

  Future<void> sendMediaMessage(String mediaPath) async {
    emit(MessageSending());
    try {
      final response = await _messageService.sendMessage(
        conversationId,
        type: 2,
        mediaPath: mediaPath,
      );
      final newMessage = MessageModel.fromJson(response['data']);
      emit(MessageSent(newMessage));
      _updateMessagesAfterSend(newMessage);
    } catch (e) {
      emit(MessageSendError('Failed to send media: $e'));
    }
  }

  void _updateMessagesAfterSend(MessageModel newMessage) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedMessages = List<MessageModel>.from(currentState.messages)
        ..add(newMessage);
      emit(ChatLoaded(updatedMessages));
    }
  }
}