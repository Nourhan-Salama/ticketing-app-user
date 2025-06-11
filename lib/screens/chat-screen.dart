import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_app/cubits/chat/chat-cubit.dart';
import 'package:final_app/cubits/chat/chat-state.dart';
import 'package:final_app/services/chat-service.dart';
import 'package:final_app/services/pusher.dart';
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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  // Debug method to refresh messages
  void _debugRefreshMessages() {
    print("=== DEBUG: Refreshing messages ===");
    _chatCubit.refreshMessages();
  }

  // Scroll to bottom when new messages arrive
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Selected image: ${image.path}");
      _chatCubit.sendMediaMessage(image.path); 
    }
  }

  Future<void> _sendVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      print("Selected video: ${video.path}");
      _chatCubit.sendMediaMessage(video.path);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    print("Sending message: $messageText");
    
    _chatCubit.sendTextMessage(messageText);
    _messageController.clear();
    
    // Auto-scroll after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  Future<File> _downloadFile(String url, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Widget _buildMediaWidget(String? mediaUrl, int type) {
    print('Building media widget - URL: $mediaUrl, Type: $type');
    
    if (mediaUrl == null || mediaUrl.isEmpty) {
      print('Media URL is null or empty');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported, color: Colors.grey),
            const SizedBox(height: 8),
            Text("No media available\nType: $type", 
                 textAlign: TextAlign.center,
                 style: const TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    String fullUrl = mediaUrl;
    if (!mediaUrl.startsWith('http')) {
      if (mediaUrl.startsWith('/')) {
        fullUrl = 'https://graduation.arabic4u.org$mediaUrl';
      } else {
        fullUrl = 'https://graduation.arabic4u.org/$mediaUrl';
      }
    }
    
    print('Final URL: $fullUrl');

    switch (type) {
      case 1: // image
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            maxHeight: 300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: fullUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                print('Loading image: $url');
                return Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                print('Error loading image: $error');
                return Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Failed to load image\n$error', 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                        ),
                        child: const Text('Retry', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

      case 2: // video
        return _VideoPlayerWidget(url: fullUrl);

      case 3: // audio
        return _AudioPlayerWidget(url: fullUrl);

      case 5: // pdf
        return FutureBuilder<File>(
          future: _downloadFile(fullUrl, "file.pdf"),
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
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("Unsupported media type: $type"),
        );
    }
  }

  Widget _buildMessageBubble(dynamic message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            message.isText
                ? Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  )
                : _buildMediaWidget(message.mediaUrl, message.type),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _chatCubit.sendMediaMessage(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _sendImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () {
                  Navigator.pop(context);
                  _sendVideo();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
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
              Expanded(
                child: Text(
                  widget.userName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Debug refresh button (remove in production)
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _debugRefreshMessages,
                tooltip: 'Refresh Messages',
              ),
              // Connection status indicator
              BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PusherService.isConnected ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      PusherService.isConnected ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocListener<ChatCubit, ChatState>(
                listener: (context, state) {
                  // Auto-scroll when new messages arrive
                  if (state is ChatLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                  }
                },
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoaded) {
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet.\nStart a conversation!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      final messages = state.messages.reversed.toList();
                      return RefreshIndicator(
                        onRefresh: () async {
                          await _chatCubit.refreshMessages();
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,  
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == widget.currentUserId;

                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                      );
                    } else if (state is ChatError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _chatCubit.loadMessages(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            // Message input area
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _showMediaOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type your message here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final isSending = state is ChatLoaded && state.isSending;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: isSending
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                          onPressed: isSending ? null : _sendMessage,
                        ),
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

class _VideoPlayerWidget extends StatefulWidget {
  final String url;

  const _VideoPlayerWidget({required this.url});

  @override
  __VideoPlayerWidgetState createState() => __VideoPlayerWidgetState();
}

class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(height: 8),
            Text('Failed to load video'),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller),
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
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
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _player.setUrl(widget.url);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 40,
        width: 40,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Failed to load audio'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePlay,
          ),
          const Icon(Icons.audiotrack),
          const SizedBox(width: 8),
          const Text('Audio Message'),
        ],
      ),
    );
  }
}
// import 'dart:async';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:final_app/cubits/chat/chat-cubit.dart';
// import 'package:final_app/cubits/chat/chat-state.dart';
// import 'package:final_app/services/chat-service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:video_player/video_player.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;

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
//     _chatCubit.sendTextMessage(_messageController.text.trim());
//     _messageController.clear();
//   }

//   Future<File> _downloadFile(String url, String filename) async {
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$filename');
//     final response = await http.get(Uri.parse(url));
//     await file.writeAsBytes(response.bodyBytes);
//     return file;
//   }

//   Widget _buildMediaWidget(String? mediaUrl, int type) {
//     print('Building media widget - URL: $mediaUrl, Type: $type');
    
//     if (mediaUrl == null || mediaUrl.isEmpty) {
//       print('Media URL is null or empty');
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.image_not_supported, color: Colors.grey),
//             const SizedBox(height: 8),
//             Text("No media available\nType: $type", 
//                  textAlign: TextAlign.center,
//                  style: const TextStyle(fontSize: 12)),
//           ],
//         ),
//       );
//     }

//     String fullUrl = mediaUrl;
//     if (!mediaUrl.startsWith('http')) {
//       if (mediaUrl.startsWith('/')) {
//         fullUrl = 'https://graduation.arabic4u.org$mediaUrl';
//       } else {
//         fullUrl = 'https://graduation.arabic4u.org/$mediaUrl';
//       }
//     }
    
//     print('Final URL: $fullUrl');

//     switch (type) {
//       case 1: // image
//         return Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//             maxHeight: 300,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: CachedNetworkImage(
//               imageUrl: fullUrl,
//               fit: BoxFit.cover,
//               placeholder: (context, url) {
//                 print('Loading image: $url');
//                 return Container(
//                   height: 150,
//                   width: 150,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               },
//               errorWidget: (context, url, error) {
//                 print('Error loading image: $error');
//                 return Container(
//                   height: 150,
//                   width: 150,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, color: Colors.red),
//                       const SizedBox(height: 8),
//                       Text('Failed to load image\n$error', 
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(fontSize: 10)),
//                       const SizedBox(height: 8),
//                       ElevatedButton(
//                         onPressed: () => setState(() {}),
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 4),
//                         ),
//                         child: const Text('Retry', style: TextStyle(fontSize: 12)),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         );

//       case 2: // video
//         return _VideoPlayerWidget(url: fullUrl);

//       case 3: // audio
//         return _AudioPlayerWidget(url: fullUrl);

//       case 5: // pdf
//         return FutureBuilder<File>(
//           future: _downloadFile(fullUrl, "file.pdf"),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done &&
//                 snapshot.hasData) {
//               return SizedBox(
//                 height: 300,
//                 child: PDFView(
//                   filePath: snapshot.data!.path,
//                 ),
//               );
//             } else {
//               return const SizedBox(
//                 height: 50,
//                 width: 50,
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             }
//           },
//         );

//       default:
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text("Unsupported media type: $type"),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => _chatCubit,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Row(
//             children: [
//               const CircleAvatar(
//                 backgroundImage: AssetImage("assets/icons/formal.jpg"),
//               ),
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
//                     final messages = state.messages.reversed.toList();
//                     return ListView.builder(
//                       reverse: true,  
//                       itemCount: state.messages.length,
//                       itemBuilder: (context, index) {
//                         final message = messages[index];
//                         final isMe = message.senderId == widget.currentUserId;

//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(
//                                 vertical: 5, horizontal: 10),
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color:
//                                   isMe ? Colors.blue : Colors.grey.shade300,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: message.isText
//                                 ? Text(
//                                     message.content,
//                                     style: TextStyle(
//                                         color: isMe
//                                             ? Colors.white
//                                             : Colors.black),
//                                   )
//                                 : _buildMediaWidget(
//                                     message.mediaUrl, message.type),
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
//                   // Fixed: Use BlocBuilder instead of BlocConsumer and check for the correct state
//                   BlocBuilder<ChatCubit, ChatState>(
//                     builder: (context, state) {
//                       final isSending = state is ChatLoaded && state.isSending;
//                       return IconButton(
//                         icon: isSending
//                             ? const SizedBox(
//                                 height: 24,
//                                 width: 24,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Icon(Icons.send, color: Colors.blue),
//                         onPressed: isSending ? null : _sendMessage,
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

// class _VideoPlayerWidget extends StatefulWidget {
//   final String url;

//   const _VideoPlayerWidget({required this.url});

//   @override
//   __VideoPlayerWidgetState createState() => __VideoPlayerWidgetState();
// }

// class __VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
//   late VideoPlayerController _controller;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.url);
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       await _controller.initialize();
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//       }
//     } catch (e) {
//       print('Error initializing video: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return const SizedBox(
//         height: 200,
//         width: 200,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: _controller.value.aspectRatio,
//       child: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           VideoPlayer(_controller),
//           IconButton(
//             icon: Icon(
//               _controller.value.isPlaying
//                   ? Icons.pause
//                   : Icons.play_arrow,
//               color: Colors.white,
//             ),
//             onPressed: () {
//               setState(() {
//                 _controller.value.isPlaying
//                     ? _controller.pause()
//                     : _controller.play();
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AudioPlayerWidget extends StatefulWidget {
//   final String url;

//   const _AudioPlayerWidget({required this.url});

//   @override
//   __AudioPlayerWidgetState createState() => __AudioPlayerWidgetState();
// }

// class __AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
//   final AudioPlayer _player = AudioPlayer();
//   bool _isPlaying = false;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAudio();
//   }

//   Future<void> _initializeAudio() async {
//     try {
//       await _player.setUrl(widget.url);
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading audio: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   void _togglePlay() async {
//     if (_isPlaying) {
//       await _player.pause();
//     } else {
//       await _player.play();
//     }
//     setState(() {
//       _isPlaying = !_isPlaying;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const SizedBox(
//         height: 40,
//         width: 40,
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return IconButton(
//       icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
//       onPressed: _togglePlay,
//     );
//   }
// }

