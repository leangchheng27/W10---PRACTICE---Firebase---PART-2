import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  final Uri songsUri = Uri.https(
    'w9-database-379ff-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  @override
  Future<List<Song>> fetchSongs() async {
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<Song> likeSong(String songId) async {
    final songUrl = Uri.https(
      'w9-database-379ff-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs/$songId.json',
    );

    final getResponse = await http.get(songUrl);
    if (getResponse.statusCode != 200) {
      throw Exception('Failed to fetch song');
    }

    final Map<String, dynamic> songJson = json.decode(getResponse.body);
    final int currentLikes = songJson['likes'] as int? ?? 0;

    final patchResponse = await http.patch(
      songUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'likes': currentLikes + 1}),
    );

    if (patchResponse.statusCode != 200) {
      throw Exception('Failed to like song');
    }

    return SongDto.fromJson(songId, {...songJson, 'likes': currentLikes + 1});
  }
}
