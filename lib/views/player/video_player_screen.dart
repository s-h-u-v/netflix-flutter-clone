import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final List<String> playlist;
  final int startIndex;
  final bool isLocalFile;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    this.playlist = const [],
    this.startIndex = 0,
    this.isLocalFile = false,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isError = false;
  bool _showControls = true;
  Timer? _hideTimer;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  bool _isCompleted = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, widget.playlist.isEmpty ? 0 : widget.playlist.length - 1);
    _initializePlayer();
    _startHideTimer();
  }

  VideoPlayerController _buildController(String url) {
    if (widget.isLocalFile) {
      return VideoPlayerController.file(File(url));
    }
    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
    return isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.asset(url);
  }

  String _currentUrl() {
    if (widget.playlist.isEmpty) return widget.videoUrl;
    return widget.playlist[_index];
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = _buildController(_currentUrl());

      // Update UI continuously for progress bar tracking
      _controller.addListener(() {
        final v = _controller.value;
        if (v.isInitialized && !v.isPlaying && v.position >= v.duration && !_isCompleted) {
          _isCompleted = true;
          _handlePlaybackCompleted();
        }
        setState(() {});
      });

      await _controller.initialize();
      setState(() {});
      _controller.play();
      _controller.setLooping(false);
    } catch (e) {
      setState(() {
        _isError = true;
      });
    }
  }

  Future<void> _playAtIndex(int newIndex) async {
    final url = widget.playlist[newIndex];
    setState(() {
      _isError = false;
      _isCompleted = false;
      _index = newIndex;
    });

    final old = _controller;
    _controller = _buildController(url);
    _controller.addListener(() {
      final v = _controller.value;
      if (v.isInitialized && !v.isPlaying && v.position >= v.duration && !_isCompleted) {
        _isCompleted = true;
        _handlePlaybackCompleted();
      }
      setState(() {});
    });

    await _controller.initialize();
    await old.pause();
    await old.dispose();
    setState(() {});
    await _controller.play();
    await _controller.setLooping(false);
  }

  void _handlePlaybackCompleted() {
    if (!mounted) return;
    final autoplay = context.read<SettingsService>().autoplayNextEpisode;
    if (!autoplay) {
      setState(() {});
      return;
    }
    if (widget.playlist.isEmpty) return;
    final nextIndex = _index + 1;
    if (nextIndex >= widget.playlist.length) return;
    _playAtIndex(nextIndex);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _seekForward10() {
    final newPos = _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPos);
    _startHideTimer();
  }

  void _seekBackward10() {
    final newPos = _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPos);
    _startHideTimer();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // 1. The Raw Video Output
              Center(
                child: _isError
                    ? const Text(
                        "Error loading video",
                        style: TextStyle(color: Colors.white),
                      )
                    : _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(color: Colors.red),
              ),

              // 2. The Transparent Interactive Controls Overlay
              if (_controller.value.isInitialized)
                AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      children: [
                        // Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.cast,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Center Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 50,
                              ),
                              onPressed: _seekBackward10,
                            ),
                            GestureDetector(
                              onTap: () {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                                _startHideTimer();
                                setState(() {});
                              },
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: Colors.white,
                                size: 80,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 50,
                              ),
                              onPressed: _seekForward10,
                            ),
                          ],
                        ),

                        if (_isCompleted && !context.read<SettingsService>().autoplayNextEpisode)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Playback ended',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                          ),

                        const Spacer(),

                        // Bottom Scrub & Tool Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress Indicator (Scrubbing Bar)
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.white24,
                                  backgroundColor: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Time, Volume, Speed Tools
                              Row(
                                children: [
                                  Text(
                                    "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),

                                  // Volume
                                  Icon(
                                    _volume > 0
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Slider(
                                      value: _volume,
                                      min: 0,
                                      max: 1,
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white24,
                                      onChanged: (val) {
                                        setState(() {
                                          _volume = val;
                                          _controller.setVolume(_volume);
                                          _startHideTimer();
                                        });
                                      },
                                    ),
                                  ),

                                  // Speed Multiplier
                                  PopupMenuButton<double>(
                                    initialValue: _playbackSpeed,
                                    icon: const Icon(
                                      Icons.speed,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onSelected: (speed) {
                                      setState(() {
                                        _playbackSpeed = speed;
                                        _controller.setPlaybackSpeed(speed);
                                        _startHideTimer();
                                      });
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 0.5,
                                        child: Text("0.5x"),
                                      ),
                                      const PopupMenuItem(
                                        value: 1.0,
                                        child: Text("1.0x (Normal)"),
                                      ),
                                      const PopupMenuItem(
                                        value: 1.25,
                                        child: Text("1.25x"),
                                      ),
                                      const PopupMenuItem(
                                        value: 1.5,
                                        child: Text("1.5x"),
                                      ),
                                      const PopupMenuItem(
                                        value: 2.0,
                                        child: Text("2.0x"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}
