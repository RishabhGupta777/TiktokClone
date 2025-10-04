import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TikTokVideoPlayer extends StatefulWidget {
  const TikTokVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);
  final String videoUrl;

  @override
  State<TikTokVideoPlayer> createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize(); // Wait for initialization to complete

    _controller..play()..setLooping(true);
    ///Upper wale code ka matlab h ki
    // videoPlayerController.play();
    // videoPlayerController.setLooping(true);

    // Update state only once after initialization
    setState(() {
      _isInitialized = true;
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _isInitialized
            ? Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
            if (!_isPlaying)
              const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 80,
              ),
          ],
        )
            : const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
