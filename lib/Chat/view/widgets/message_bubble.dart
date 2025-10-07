import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:tiktok_clone/Chat/controller/ChatProvider.dart';

class MessageBubble extends StatefulWidget {
  final String id;
  final String text;
  final String sender;
  final bool isMe;
  final Timestamp? timestamp;
  final bool isRead;
  final List<dynamic>? mediaUrls;
  final String? type;

  const MessageBubble({
    super.key,
    required this.id,
    required this.text,
    required this.sender,
    required this.isMe,
    required this.timestamp,
    required this.isRead,
    this.mediaUrls,
    this.type,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final List<VideoPlayerController> _videoControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize video players if there are videos
    if (widget.type == 'video' && widget.mediaUrls != null) {
      for (var url in widget.mediaUrls!) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) {
            setState(() {});
          });
        _videoControllers.add(controller);
      }
    }
  }

  @override
  void dispose() {
    for (var c in _videoControllers) {
      c.dispose();
    }
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
                    // 🖼️ MEDIA SECTION
                    if (widget.mediaUrls != null && widget.mediaUrls!.isNotEmpty)
                      _buildMediaGrid(context),

                    // 💬 TEXT SECTION
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

                    // 🕓 TIME + READ ICON
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeString,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                          if (widget.isMe) const SizedBox(width: 5),
                          if (widget.isMe)
                            widget.isRead
                                ? const Icon(Icons.done_all,
                                size: 16, color: Colors.blue)
                                : const Icon(Icons.done, size: 16),
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
    final urls = widget.mediaUrls!;
    int itemCount = urls.length;

    // WhatsApp style grid (max 4 visible, rest shows "+N")
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemCount == 1 ? 1 : (itemCount == 2 ? 2 : 3),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: itemCount > 4 ? 4 : itemCount,
      itemBuilder: (context, index) {
        final url = urls[index];
        final isVideo = widget.type == 'video';

        Widget mediaWidget;

        if (isVideo) {
          final controller = _videoControllers[index];
          mediaWidget = controller.value.isInitialized
              ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              const Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 40),
            ],
          )
              : const Center(child: CircularProgressIndicator());
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
        if (index == 3 && itemCount > 4) {
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

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: mediaWidget,
        );
      },
    );
  }
}
