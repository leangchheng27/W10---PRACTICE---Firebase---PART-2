import 'package:flutter/material.dart';
import '../../../../model/artist/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.comment, color: Colors.grey),
            SizedBox(width: 12),
            Expanded(child: Text(comment.text)),
          ],
        ),
      ),
    );
  }
}