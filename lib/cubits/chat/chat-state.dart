

import 'package:final_app/models/message-model.dart';


abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  
  const ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  
  const ChatError(this.message);
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {
  final MessageModel message;
  
  const MessageSent(this.message);
}

class MessageSendError extends ChatState {
  final String error;
  
  const MessageSendError(this.error);
}