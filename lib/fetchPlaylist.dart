import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

final String clientId = "b8219c801d1d436f9295c4d08881d3b3";
final String clientSecret = "be5dffe517df49f8a6bcf936fede67a2";
// final String redirectUri = "musitify://callback";
final String redirectUri = Uri.encodeComponent('audify://callback');
final String scopes = Uri.encodeComponent('user-read-private, user-read-email');
final String state = DateTime.now().millisecondsSinceEpoch.toString();
final String callbackScheme = 'audify';
// final callbackScheme = redirectUri.split(':').first; // "audify"

// String state = generateRandomString(16);

String generateRandomString(int length) {
  final random = Random();
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final randomString = List.generate(length,
      (index) => availableChars[random.nextInt(availableChars.length)]).join();

  return randomString;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _accessToken;
  List<Map<String, dynamic>> _playlists = [];

  Future<void> authenticate() async {
    print('authenticate');
    print('callbackScheme');
    print(callbackScheme);

    try {
      // final authUrl =
      //     "https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=$scopes&state=$state";

      final String authUrl = 'https://accounts.spotify.com/authorize'
          '?client_id=$clientId'
          '&response_type=code'
          '&redirect_uri=$redirectUri'
          '&scope=$scopes'
          '&state=$state';

      print('authUrl');
      print(authUrl);
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: callbackScheme,
      );

      print('Starting authentication...');
      print('result');
      print(result);

      final code = Uri.parse(result).queryParameters['code'];
      print('code');
      print(code);
      if (code != null) {
        await getAccessToken(code);
      }
    } catch (e) {
      debugPrint("Error during authentication: $e");
    }
  }

  Future<void> getAccessToken(String code) async {
    try {
      final response = await Dio().post(
        "https://accounts.spotify.com/api/token",
        data: {
          "grant_type": "authorization_code",
          "code": code,
          "redirect_uri": redirectUri,
          "client_id": clientId,
          "client_secret": clientSecret,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      print('response');
      print(response);

      setState(() {
        _accessToken = response.data['access_token'];
      });
      print('_accessToken');
      print(_accessToken);

      fetchPlaylists();
    } catch (e) {
      debugPrint("Error fetching access token: $e");
    }
  }

  Future<void> fetchPlaylists() async {
    if (_accessToken == null) return;

    try {
      final response = await Dio().get(
        "https://api.spotify.com/v1/me/playlists",
        options: Options(headers: {
          "Authorization": "Bearer $_accessToken",
        }),
      );

      setState(() {
        _playlists = (response.data['items'] as List)
            .map((playlist) => {
                  "name": playlist['name'],
                  "id": playlist['id'],
                })
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching playlists: $e");
    }
  }

  Future<void> fetchSongs(String playlistId) async {
    if (_accessToken == null) return;

    try {
      final response = await Dio().get(
        "https://api.spotify.com/v1/playlists/$playlistId/tracks",
        options: Options(headers: {
          "Authorization": "Bearer $_accessToken",
        }),
      );

      final songs = (response.data['items'] as List)
          .map((item) => item['track']['name'])
          .toList();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Songs in Playlist"),
          content: Text(songs.join("\n")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error fetching songs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Playlists')),
      body: Column(
        children: [
          if (_accessToken == null)
            ElevatedButton(
              onPressed: authenticate,
              child: const Text("Login with Spotify"),
            )
          else if (_playlists.isEmpty)
            const CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return ListTile(
                    title: Text(playlist['name']),
                    onTap: () => fetchSongs(playlist['id']),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
