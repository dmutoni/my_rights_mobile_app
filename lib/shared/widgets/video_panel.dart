import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class VideoPanel extends StatefulWidget {
  final String videoUrl;

  const VideoPanel({super.key, required this.videoUrl});

  @override
  State<VideoPanel> createState() => _VideoPanelState();
}

class _VideoPanelState extends State<VideoPanel> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showOverlay = true;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _showOverlay = !_controller.value.isPlaying;
        });
        _controller.addListener(_videoListener);
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
      });
  }

  void _videoListener() {
    if (!_controller.value.isPlaying && !_showOverlay) {
      setState(() {
        _showOverlay = true;
      });
    }
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showOverlay = true;
        _overlayTimer?.cancel();
      } else {
        _controller.play();
        _showOverlay = true;
        _startOverlayTimer();
      }
    });
  }

  void _onVideoTap() {
    if (_showOverlay) {
      setState(() {
        _showOverlay = false;
      });
      _overlayTimer?.cancel();
    } else {
      setState(() {
        _showOverlay = true;
      });
      if (_controller.value.isPlaying) {
        _startOverlayTimer();
      }
    }
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 2), () {
      if (_controller.value.isPlaying) {
        setState(() {
          _showOverlay = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).appBarTheme.foregroundColor,
      ),
      child: _isInitialized
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onVideoTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    // Play/Pause Overlay
                    AnimatedOpacity(
                      opacity: _showOverlay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .appBarTheme
                              .foregroundColor
                              ?.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: _togglePlayPause,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Theme.of(context)
                                .appBarTheme
                                .backgroundColor,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    // Progress Indicator at the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: false,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          padding: EdgeInsets.zero,
                          colors: VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.white.withValues(alpha: .5),
                            backgroundColor: Colors.white.withValues(alpha: .2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color:
                            Theme.of(context).appBarTheme.backgroundColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load video',
                        style: TextStyle(
                            color: Theme.of(context)
                                .appBarTheme
                                .backgroundColor,
                            fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context)
                          .appBarTheme
                          .backgroundColor),
                ),
    );
  }
}
