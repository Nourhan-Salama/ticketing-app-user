import 'dart:io';
import 'package:final_app/cubits/chat/chat-cubit.dart';
import 'package:final_app/cubits/chat/chat-state.dart';
import 'package:final_app/services/chat-service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat-screen';
  final String userName;
  final String conversationId;
  final String currentUserId;

  const ChatScreen({
    Key? key,
    required this.userName,
    required this.conversationId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCubit _chatCubit;
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit(
      messageService: MessageService(),
      conversationId: widget.conversationId,
      currentUserId: widget.currentUserId,
    );
    _chatCubit.loadMessages();
  }

  @override
  void dispose() {
    _chatCubit.close();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _chatCubit.sendMediaMessage(image.path); 
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _chatCubit.sendTextMessage(_messageController.text.trim());
    _messageController.clear();
  }

  Future<File> _downloadFile(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Widget _buildMediaWidget(String? mediaUrl, int type) {
    if (mediaUrl == null) return const Text("No media");

    switch (type) {
      case 1: // image
        return Image.network(
          mediaUrl,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 50,
              width: 50,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );

      case 2: // video
        return FutureBuilder(
          future: VideoPlayerController.network(mediaUrl).initialize().then((_) => VideoPlayerController.network(mediaUrl)),
          builder: (context, AsyncSnapshot<VideoPlayerController> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final controller = snapshot.data!;
              return AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(controller),
                    IconButton(
                      icon: Icon(
                        controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox(
                height: 50,
                width: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        );

      case 3: // audio
        return _AudioPlayerWidget(url: mediaUrl);

      case 5: // pdf
        return FutureBuilder<File>(
          future: _downloadFile(mediaUrl, "file.pdf"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return SizedBox(
                height: 300,
                child: PDFView(
                  filePath: snapshot.data!.path,
                ),
              );
            } else {
              return const SizedBox(
                height: 50,
                width: 50,
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        );

      default:
        return const Text("Unsupported media type");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _chatCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/icons/formal.jpg"),
              ),
              const SizedBox(width: 10),
              Text(widget.userName),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    return ListView.builder(
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId == widget.currentUserId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.blue : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: message.isText
                                ? Text(
                                    message.content,
                                    style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black),
                                  )
                                : _buildMediaWidget(
                                    message.mediaUrl, message.type),
                          ),
                        );
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocConsumer<ChatCubit, ChatState>(
                    listener: (context, state) {
                      if (state is MessageSendError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error)),
                        );
                      }
                    },
                    builder: (context, state) {
                      return IconButton(
                        icon: state is MessageSending
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send, color: Colors.blue),
                        onPressed:
                            state is MessageSending ? null : _sendMessage,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPlayerWidget extends StatefulWidget {
  final String url;

  const _AudioPlayerWidget({required this.url});

  @override
  __AudioPlayerWidgetState createState() => __AudioPlayerWidgetState();
}

class __AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
      onPressed: _togglePlay,
    );
  }
}


// done 
// import 'dart:io';
// import 'package:final_app/cubits/chat/chat-cubit.dart';
// import 'package:final_app/cubits/chat/chat-state.dart';
// import 'package:final_app/services/chat-service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';


// class ChatScreen extends StatefulWidget {
//   static const String routeName = '/chat-screen';
//   final String userName;
//   final String conversationId;
//   final String currentUserId;

//   const ChatScreen({
//     Key? key,
//     required this.userName,
//     required this.conversationId,
//     required this.currentUserId,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late final ChatCubit _chatCubit;
//   final TextEditingController _messageController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _chatCubit = ChatCubit(
//       messageService: MessageService(),
//       conversationId: widget.conversationId,
//       currentUserId: widget.currentUserId,
//     );
//     _chatCubit.loadMessages();
//   }

//   @override
//   void dispose() {
//     _chatCubit.close();
//     _messageController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       _chatCubit.sendMediaMessage(image.path);
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;
//     _chatCubit.sendTextMessage(_messageController.text);
//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _chatCubit,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             children: [
//               CircleAvatar(backgroundImage: AssetImage("assets/icons/formal.jpg")),
//               const SizedBox(width: 10),
//               Text(widget.userName),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: BlocBuilder<ChatCubit, ChatState>(
//                 builder: (context, state) {
//                   if (state is ChatLoaded) {
//                     return ListView.builder(
//                       itemCount: state.messages.length,
//                       itemBuilder: (context, index) {
//                         final message = state.messages[index];
//                         final isMe = message.senderId == widget.currentUserId;
                        
//                         return Align(
//                           alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: isMe ? Colors.blue : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: message.isText
//                                 ? Text(
//                                     message.content,
//                                     style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                                   )
//                                 : message.mediaUrl != null
//                                     ? Image.network(message.mediaUrl!)
//                                     : const Text('Media message'),
//                           ),
//                         );
//                       },
//                     );
//                   } else if (state is ChatError) {
//                     return Center(child: Text(state.message));
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.camera_alt),
//                     onPressed: _sendImage,
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: InputDecoration(
//                         hintText: "Type your message here...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   BlocConsumer<ChatCubit, ChatState>(
//                     listener: (context, state) {
//                       if (state is MessageSendError) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text(state.error)),
//                         );
//                       }
//                     },
//                     builder: (context, state) {
//                       return IconButton(
//                         icon: state is MessageSending
//                             ? const CircularProgressIndicator()
//                             : const Icon(Icons.send, color: Colors.blue),
//                         onPressed: state is MessageSending ? null : _sendMessage,
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;

// class ChatScreen extends StatefulWidget {
//  static const String routeName = '/chat-screen';
//   final String userName;

//   ChatScreen({required this.userName});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late WebSocketChannel channel;
//   final TextEditingController _messageController = TextEditingController();
//   final List<Map<String, dynamic>> messages = [];

//   @override
//   void initState() {
//     super.initState();
//     connectToWebSocket();
//   }

//   void connectToWebSocket() {
//     channel = WebSocketChannel.connect(
//       Uri.parse(''), 
//     );

//     channel.stream.listen((message) {
//       setState(() {
//         messages.add({"text": message, "isMe": false});
//       });
//     });
//   }

//   void sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     String message = _messageController.text;

//     setState(() {
//       messages.add({"text": message, "isMe": true});
//     });

//     channel.sink.add(message);

//     _messageController.clear();
//   }

//   @override
//   void dispose() {
//     channel.sink.close(status.goingAway);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: AssetImage("assets/icons/formal.jpg"), 
//             ),
//             const SizedBox(width: 10),
//             Text(widget.userName),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 bool isMe = messages[index]['isMe'];
//                 return Align(
//                   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isMe ? Colors.blue : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       messages[index]['text'],
//                       style: TextStyle(color: isMe ? Colors.white : Colors.black),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: "Type your message here...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

