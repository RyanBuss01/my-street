import '../../models/classes/reply.dart';
import '../../models/classes/user.dart';

class Post {
  final int id;
  final int userId;
  final DateTime createdAt;
  final String type;
  final String media;
  final double latitude;
  final double longitude;
  final User? user;
  final int? stackCount;
  String? caption;
  Reply? myReply;


  Post({required this.id, required this.userId, required this.createdAt, required this.type, required this.media, required this.latitude, required this.longitude, this.caption, this.myReply, this.user, this.stackCount});

  factory  Post.fromDoc(dynamic json, {bool getUser = false, int? count}) {
    return Post(
        id: json['post_id'],
        userId: json['user_id'],
        createdAt: DateTime.parse(json['dt'].toString()),
        type: json['post_type'],
        media: json['media'],
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
        caption: json['caption'],
        myReply: json['reply_id'] != null ? Reply.fromDoc(json) : null,
        user: getUser ? User.fromMinDoc(json) : null,
        stackCount: count
    );
  }

  static Post parse(dynamic data) => Post.fromDoc(data['post'], count: data['count']);
}