import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/artist/artist.dart';
import '../../../model/artist/comment.dart';
import '../../../model/songs/song.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/comment_dto.dart';
import '../../dtos/song_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  static const String _baseHost =
      'w9-database-379ff-default-rtdb.asia-southeast1.firebasedatabase.app';

  final Uri artistsUri = Uri.https(_baseHost, '/artists.json');

  List<Artist>? _cachedArtists;

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (!forceFetch && _cachedArtists != null) return _cachedArtists!;

    final response = await http.get(artistsUri);
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      List<Artist> result = [];
      for (final entry in json.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }
      _cachedArtists = result;
      return result;
    } else {
      throw Exception('Failed to load artists');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    final uri = Uri.https(_baseHost, '/songs.json');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> songsJson = jsonDecode(response.body);
      List<Song> result = [];
      for (final entry in songsJson.entries) {
        final song = SongDto.fromJson(entry.key, entry.value);
        if (song.artistId == artistId) result.add(song); // ← filter by artistId
      }
      return result;
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    final uri = Uri.https(_baseHost, '/comments.json',
        {'orderBy': '"artistId"', 'equalTo': '"$artistId"'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return []; // ← no comments yet
      Map<String, dynamic> commentsJson = body;
      List<Comment> result = [];
      for (final entry in commentsJson.entries) {
        result.add(CommentDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<Comment> postComment(String artistId, String text) async {
    final uri = Uri.https(_baseHost, '/comments.json');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'artistId': artistId, 'text': text}),
    );

    if (response.statusCode == 200) {
      final String newId = jsonDecode(response.body)['name']; // ← Firebase returns new ID
      return Comment(id: newId, artistId: artistId, text: text);
    } else {
      throw Exception('Failed to post comment');
    }
  }
}