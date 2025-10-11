import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_clone/Chat/view/widgets/MediaPreviewScreen.dart';
import 'package:tiktok_clone/TikTok/view/widgets/MediaVideoPlayer.dart';
import 'package:video_player/video_player.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';

class MessageBubble extends StatefulWidget {
  final String id;
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp? timestamp;
  final bool isRead;
  List<Map<String,String>> mediaUrls;

  MessageBubble({
    super.key,
    required this.id,
    required this.text,
    required this.sender,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    required this.mediaUrls,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

// Use a Map to associate the URL with its controller for easier management
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    // 💡 Initialize controllers for all video media
    _initializeVideoControllers();
  }

  void _initializeVideoControllers() {
    for (var item in widget.mediaUrls) {
      if (item['type'] == 'video') {
        final url = item['url']!;
        if (!_videoControllers.containsKey(url)) {
          final controller = VideoPlayerController.networkUrl(Uri.parse(url)) // Use networkUrl
            ..initialize().then((_) {
              // Only call setState if the widget is still mounted
              if (mounted) {
                setState(() {}); // Rebuild to show the video once initialized
              }
            });
          _videoControllers[url] = controller;
        }
      }
    }
  }

  @override
  void dispose() {
    // 🗑️ Dispose of all controllers when the widget is removed
    _videoControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final bool selected = chatProvider.isMessageSelected(widget.id);

    String timeString = '';
    if (widget.timestamp != null) {
      timeString = DateFormat.jm().format(widget.timestamp!.toDate());
    }

    return GestureDetector(
      onLongPress: () => chatProvider.selectMessage(widget.id, widget.text, widget.isMe),
      onTap: () {
        if (chatProvider.isSelectionActive) {
          chatProvider.selectMessage(widget.id, widget.text, widget.isMe);
        }
      },
      child: Container(
        width: double.infinity,
        color: selected ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisAlignment: widget.isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isMe ? const Color(0xFFE7FFC6) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(widget.isMe ? 18 : 0),
                    bottomRight: Radius.circular(widget.isMe ? 0 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// MEDIA SECTION
                    if (widget.mediaUrls != null && widget.mediaUrls.isNotEmpty)
                      SizedBox(
                        width:280,
                          height:280,
                          child: _buildMediaGrid(context)),

                    /// TEXT SECTION
                    if (widget.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),

                    /// TIME + READ ICON
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeString,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                          if (widget.isMe) const SizedBox(width: 5),
                          if (widget.isMe)
                            widget.isRead
                                ? const Icon(Icons.done_all,
                                size: 16, color: Colors.blue)
                                : const Icon(Icons.done, size: 16,color:Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a WhatsApp-like grid for multiple images/videos
  Widget _buildMediaGrid(BuildContext context) {
    final mediaItems = widget.mediaUrls ?? [];
    int itemCount = mediaItems.length;

    // WhatsApp style grid (max 4 visible, rest shows "+N")
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemCount == 1 ? 1 : (itemCount == 2 ? 2 : 2),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: mediaItems.length > 4 ? 4 : mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index] as Map<String, dynamic>;
        final url = item['url'];
        final type = item['type'];

        Widget mediaWidget;

        if (type == 'video') {
              mediaWidget= Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: MediaVideoPlayer(videoUrl: url),
              ),
              IconButton(
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MediaPreviewScreen(
                        mediaItems: mediaItems.cast<Map<String, dynamic>>(),
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_fill,
                    color: Colors.white, size: 40),
              ),
            ],
          );
        } else {
          mediaWidget = CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, _, __) => const Icon(Icons.error),
          );
        }

        // If more than 4 media, show overlay "+N"
        if (index == 3 && mediaItems.length > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              mediaWidget,
              Container(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    "+${itemCount - 4}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        }

        return Consumer<ChatProvider>(
          builder: (context,provider,child) {
            return GestureDetector(
                onTap: () {
                  provider.isSelectionActive
                      ? provider.selectMessage(widget.id, widget.text, widget.isMe)
                      : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MediaPreviewScreen(
                        mediaItems: mediaItems.cast<Map<String, dynamic>>(),
                        initialIndex: index,
                      ),
                    ),
                  );
                },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: mediaWidget,
            ),);
          }
        );
      },
    );
  }
}
