import 'package:flutter/material.dart';
import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/artist/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';

class ArtistViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final Artist artist;

  AsyncValue<List<Song>> songsValue = AsyncValue.loading();
  AsyncValue<List<Comment>> commentsValue = AsyncValue.loading();
  Exception? commentError;

  ArtistViewModel({
    required this.artistRepository,
    required this.artist,
  }) {
    _init();
  }

  void _init() {
    fetchData();
  }

  void fetchData() async {
    songsValue = AsyncValue.loading();
    commentsValue = AsyncValue.loading();
    notifyListeners();

    try {
      // fetch songs and comments in parallel
      final results = await Future.wait([
        artistRepository.fetchArtistSongs(artist.id),
        artistRepository.fetchArtistComments(artist.id),
      ]);

      songsValue = AsyncValue.success(results[0] as List<Song>);
      commentsValue = AsyncValue.success(results[1] as List<Comment>);
    } catch (e) {
      songsValue = AsyncValue.error(e);
      commentsValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  void addComment(String text) async {
    // validate empty comment
    if (text.trim().isEmpty) return;

    try {
      final newComment = await artistRepository.postComment(artist.id, text);

      // update local state without re-fetching
      final currentComments = commentsValue.data ?? [];
      commentsValue = AsyncValue.success([...currentComments, newComment]);
      commentError = null;
    } catch (e) {
      commentError = e as Exception;
    }
    notifyListeners();
  }
}