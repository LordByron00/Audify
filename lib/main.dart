import 'package:flutter/material.dart';
import 'package:musitify/audio.dart';
import 'package:musitify/search.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YouTubeSearchScreen(),
    );
  }
}

class AudioOnlyYouTube extends StatefulWidget {
  @override
  _AudioOnlyYouTubeState createState() => _AudioOnlyYouTubeState();
}

class _AudioOnlyYouTubeState extends State<AudioOnlyYouTube> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // If the requirement is just to play a single video.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'fQ5ZfDcmP3o',
      autoPlay: true,
      params: const YoutubePlayerParams(
        enableKeyboard: true,
        showFullscreenButton: true,
        showVideoAnnotations: false,
        enableJavaScript: true,
        strictRelatedVideos: true,
        playsInline: true,
        interfaceLanguage: 'en',
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio-Only YouTube Player'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Hidden YouTube Player
          SizedBox(
            height: 1, // Minimal height
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  print('Triggering play');
                  _controller.playVideo();
                },
                child: const Text('Play Audio'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('Triggering pause');
                  _controller.pauseVideo();
                },
                child: const Text('Pause Audio'),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
