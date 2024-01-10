
import '../../models/classes/user.dart';

class CommentModel {
  final int id;
  final int postId;
  final String message;
  final bool isLiked;
  final int likeCount;
  final DateTime createdAt;
  final User userdata;

  CommentModel({required this.id, required this.postId, required this.message, required this.isLiked, required this.likeCount, required this.createdAt, required this.userdata});

  factory CommentModel.fromDoc(dynamic json) {
     return CommentModel(
         id: json['comment_id'],
         postId: json['post_id'],
         message: json['message'].toString(),
         isLiked: json['commentLike_id'] != null,
         likeCount: json['likeCount'],
         createdAt: DateTime.parse(json['dt'].toString()),
         userdata: User.fromDoc(json)
    );
  }
}
