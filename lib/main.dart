import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const WaqasPlayerApp());
}

class WaqasPlayerApp extends StatelessWidget {
  const WaqasPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waqas Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MediaPlayerScreen(),
    );
  }
}

class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({super.key});

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isVideoMode = true;
  bool _isPortraitLocked = false;
  bool _isPlaying = false;
  bool _isLongPressing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer?.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer?.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });

    _audioPlayer?.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _togglePortraitLock() {
    setState(() {
      _isPortraitLocked = !_isPortraitLocked;
    });

    if (_isPortraitLocked) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _onLongPressStart() {
    setState(() {
      _isLongPressing = true;
    });

    if (_isVideoMode && _videoController != null) {
      _videoController!.setPlaybackSpeed(2.0);
    } else if (_audioPlayer != null) {
      _audioPlayer!.setSpeed(2.0);
    }
  }

  void _onLongPressEnd() {
    setState(() {
      _isLongPressing = false;
    });

    if (_isVideoMode && _videoController != null) {
      _videoController!.setPlaybackSpeed(1.0);
    } else if (_audioPlayer != null) {
      _audioPlayer!.setSpeed(1.0);
    }
  }

  void _togglePlayPause() {
    if (_isVideoMode && _videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } else if (_audioPlayer != null) {
      if (_isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.play();
      }
    }
  }

  void _loadSampleVideo() async {
    // For demo purposes, using a sample video URL
    // In a real app, you would implement file picker
    const videoUrl = 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
    
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    await _videoController!.initialize();
    
    setState(() {
      _isVideoMode = true;
      _duration = _videoController!.value.duration;
    });

    _videoController!.addListener(() {
      setState(() {
        _position = _videoController!.value.position;
        _isPlaying = _videoController!.value.isPlaying;
      });
    });
  }

  void _loadSampleAudio() async {
    // For demo purposes, using a sample audio URL
    // In a real app, you would implement file picker
    const audioUrl = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
    
    try {
      await _audioPlayer!.setUrl(audioUrl);
      setState(() {
        _isVideoMode = false;
      });
    } catch (e) {
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waqas Player'),
        actions: [
          IconButton(
            icon: Icon(_isPortraitLocked ? Icons.screen_lock_portrait : Icons.screen_rotation),
            onPressed: _togglePortraitLock,
            tooltip: _isPortraitLocked ? 'Unlock Portrait' : 'Lock Portrait',
          ),
        ],
      ),
      body: Column(
        children: [
          // Media Display Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isVideoMode && _videoController != null
                  ? GestureDetector(
                      onLongPressStart: (_) => _onLongPressStart(),
                      onLongPressEnd: (_) => _onLongPressEnd(),
                      onTap: _togglePlayPause,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                          if (_isLongPressing)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '2x Speed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onLongPressStart: (_) => _onLongPressStart(),
                      onLongPressEnd: (_) => _onLongPressEnd(),
                      onTap: _togglePlayPause,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.music_note,
                            size: 100,
                            color: Colors.white54,
                          ),
                          if (_isLongPressing)
                            Positioned(
                              top: 20,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '2x Speed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ),
          
          // Controls Area
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Bar
                  Row(
                    children: [
                      Text(_formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          value: _duration.inMilliseconds > 0
                              ? _position.inMilliseconds / _duration.inMilliseconds
                              : 0.0,
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds: (value * _duration.inMilliseconds).round(),
                            );
                            if (_isVideoMode && _videoController != null) {
                              _videoController!.seekTo(newPosition);
                            } else if (_audioPlayer != null) {
                              _audioPlayer!.seek(newPosition);
                            }
                          },
                        ),
                      ),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Play Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40,
                        onPressed: () {
                          // Implement previous functionality
                        },
                      ),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        iconSize: 60,
                        onPressed: _togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40,
                        onPressed: () {
                          // Implement next functionality
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Mode Toggle and Load Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text('Load Video'),
                        onPressed: _loadSampleVideo,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.audio_file),
                        label: const Text('Load Audio'),
                        onPressed: _loadSampleAudio,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    'Long press on media area for 2x speed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

