

import 'package:final_app/models/message-model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isSending;

  const ChatLoaded(this.messages, {this.isSending = false});
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}

