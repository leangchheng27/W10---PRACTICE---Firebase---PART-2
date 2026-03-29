import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../model/artist/artist.dart';
import '../../../../../model/songs/song.dart';
import '../../../../../model/artist/comment.dart';
import '../../../utils/async_value.dart';
import '../view_model/artist_view_model.dart';
import 'comment_tile.dart';

class ArtistContent extends StatefulWidget {
  const ArtistContent({super.key, required this.artist});

  final Artist artist;

  @override
  State<ArtistContent> createState() => _ArtistContentState();
}

class _ArtistContentState extends State<ArtistContent> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(BuildContext context, ArtistViewModel mv) {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comment cannot be empty!')),
      );
      return;
    }
    mv.addComment(_commentController.text.trim());
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ArtistViewModel mv = context.watch<ArtistViewModel>();

    if (mv.commentError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not post comment. Please try again.')),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.artist.name)),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          left: 16,
          right: 8,
          top: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                onSubmitted: (_) => _submitComment(context, mv),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: () => _submitComment(context, mv),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        NetworkImage(widget.artist.imageUrl.toString()),
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.artist.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.artist.genre,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Songs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSongs(mv.songsValue),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildComments(mv.commentsValue),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSongs(AsyncValue<List<Song>> songsValue) {
    switch (songsValue.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Center(
          child: Text('Failed to load songs',
              style: TextStyle(color: Colors.red)),
        );
      case AsyncValueState.success:
        final songs = songsValue.data!;
        if (songs.isEmpty) {
          return Center(child: Text('No songs found'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(songs[index].title),
            subtitle: Text('${songs[index].duration.inMinutes} mins'),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(songs[index].imageUrl.toString()),
            ),
          ),
        );
    }
  }

  Widget _buildComments(AsyncValue<List<Comment>> commentsValue) {
    switch (commentsValue.state) {
      case AsyncValueState.loading:
        return Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Center(
          child: Text('Failed to load comments',
              style: TextStyle(color: Colors.red)),
        );
      case AsyncValueState.success:
        final comments = commentsValue.data!;
        if (comments.isEmpty) {
          return Center(child: Text('No comments yet. Be the first!'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) =>
              CommentTile(comment: comments[index]),
        );
    }
  }
}