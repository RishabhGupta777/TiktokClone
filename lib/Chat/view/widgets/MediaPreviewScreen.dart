import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/TikTok/view/widgets/MediaVideoPlayer.dart';
import 'package:tiktok_clone/TikTok/view/widgets/TikTokVideoPlayer.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> mediaItems;
  final int initialIndex;

  const MediaPreviewScreen({
    Key? key,
    required this.mediaItems,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final mediaItems = widget.mediaItems;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${_currentIndex + 1}/${mediaItems.length}"),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemCount: mediaItems.length,
        itemBuilder: (context, index) {
          final item = mediaItems[index];
          final url = item['url'];
          final type = item['type'];

          if (type == 'video') {
            return MediaVideoPlayer(videoUrl: url);
          } else {
            return Center(
              child: ClipRect(
                child: InteractiveViewer(
                  panEnabled: true, // allow drag
                  scaleEnabled: true, // allow zoom
                  minScale: 1.0,
                  maxScale: 4.0, // zoom up to 4x
                  boundaryMargin: const EdgeInsets.only(bottom:0),
                  child: SizedBox.expand(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (context, _) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, __, ___) => const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
