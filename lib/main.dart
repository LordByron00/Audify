import 'package:flutter/material.dart';
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
      home: AudioOnlyYouTube(),
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
    _controller = YoutubePlayerController(
      initialVideoId: 'M7lc1UVf-VE', // Replace with your YouTube video ID
      params: const YoutubePlayerParams(
        autoPlay: true,
        mute: false,
        showFullscreenButton: false,
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
          Opacity(
            opacity: 0.0, // Makes the player invisible
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              _controller.play();
            },
            child: const Text('Play Audio'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.pause();
            },
            child: const Text('Pause Audio'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
