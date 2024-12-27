import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YouTubeSearchScreen(),
    );
  }
}

class YouTubeSearchScreen extends StatefulWidget {
  @override
  _YouTubeSearchScreenState createState() => _YouTubeSearchScreenState();
}

class _YouTubeSearchScreenState extends State<YouTubeSearchScreen> {
  final String apiKey = 'AIzaSyChK-uhlHk5iLeFuKjsedCxifjDIydawTE';
  final TextEditingController _controller = TextEditingController();
  List<String> videoUrls = [];

  // Function to search for YouTube videos
  Future<void> searchVideos(String query) async {
    final url =
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> urls = [];
      for (var item in data['items']) {
        final videoId = item['id']['videoId'];
        final videoUrl = 'https://www.youtube.com/watch?v=$videoId';
        urls.add(videoUrl);
      }
      setState(() {
        videoUrls = urls;
      });
    } else {
      throw Exception('Failed to load YouTube videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YouTube Video Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search YouTube',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                searchVideos(_controller.text);
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: videoUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(videoUrls[index]),
                    onTap: () {
                      // Optionally, you could open the URL in a browser or video player
                      print('Opening video: ${videoUrls[index]}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
