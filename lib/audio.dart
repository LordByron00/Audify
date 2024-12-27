import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class YouTubeAudioPlayer extends StatefulWidget {
  @override
  _YouTubeAudioPlayerState createState() => _YouTubeAudioPlayerState();
}

class _YouTubeAudioPlayerState extends State<YouTubeAudioPlayer> {
  final _audioPlayer = AudioPlayer();
  String audioUrl = "";
  final TextEditingController _youtubeUrlController = TextEditingController();
  bool isloading = false;
  bool hasLoaded = false;
  bool isPlaying = false;

  Future<void> fetchAudioUrl(String youtubeUrl) async {
    final Uri apiEndpoint = Uri.parse(
        'http://192.168.1.8:5000/get_audio?url=$youtubeUrl'); // Use your server's URL
    try {
      final response = await http.get(apiEndpoint);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          audioUrl = data['audio_url'];
          hasLoaded = true;
          isloading = false;
        });
        await _audioPlayer.setUrl(audioUrl);
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Failed to fetch audio URL: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Audio Player')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _youtubeUrlController,
            decoration: InputDecoration(
              labelText: 'Enter YouTube URL',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  isloading = true;
                });
                String url = _youtubeUrlController.text;
                print(url);
                await fetchAudioUrl(url);
                _youtubeUrlController.text = '';
              },
              child: Text(!isloading ? 'Fetch Audio' : 'Fetching...')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (hasLoaded) {
                    !isPlaying ? _audioPlayer.play() : _audioPlayer.pause();
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  }
                },
                child: Text(!isPlaying ? 'Play' : 'Pause'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
