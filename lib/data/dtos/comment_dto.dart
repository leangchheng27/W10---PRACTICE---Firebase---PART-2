import '../../model/artist/comment.dart';

class CommentDto {
  static const String artistIdKey = 'artistId';
  static const String textKey = 'text';

  static Comment fromJson(String id, Map<String, dynamic> json) {
    assert(json[artistIdKey] is String, 'Missing or invalid artistId: ${json[artistIdKey]}');
    assert(json[textKey] is String, 'Missing or invalid text: ${json[textKey]}');

    return Comment(
      id: id,
      artistId: json[artistIdKey] as String,
      text: json[textKey] as String,
    );
  }

  static Map<String, dynamic> toJson(Comment comment) {
    return {
      artistIdKey: comment.artistId,
      textKey: comment.text,
    };
  }
}