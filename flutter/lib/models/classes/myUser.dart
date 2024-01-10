import 'package:geolocator/geolocator.dart';
import '../../models/classes/post.dart';
import '../../models/classes/upload.dart';

class MyUser {
  final int id;
  final String? email;
  final String displayName;
  final String username;
  final String? bio;
  final String avatar;
  final bool hasRequest;
  final int? mainStoryId;
  final int? userCount;
  final int? postCount;
  List<Upload> uploads;
  Position currentPosition;
  List<Post> posts;
  Future? postsFuture;


  MyUser({
    required this.id,
    this.email,
    required this.displayName,
    required this.username,
    this.bio,
    required this.avatar,
    required this.hasRequest,
    this.mainStoryId,
    this.userCount,
    this.postCount,
    required this.uploads,
    required this.currentPosition,
    this.postsFuture,
    required this.posts
  });


  factory MyUser.fromDoc(dynamic json,
      {isProfilePage = false, isPersonalData = false, isMe = false, int? count, required Position pos}) {
    return MyUser(
        id: json['user_id'],
        email: isPersonalData ? json['email'] : null,
        displayName: json['displayName'],
        username: json['username'],
        bio: isProfilePage || isMe ? json['bio'] : null,
        avatar: json['avatar'],
        hasRequest: !isMe ? false : json['friendRequest_id'] != null
            ? true
            : false,
        mainStoryId: json['story_id'],
        userCount: count,
      uploads: [],
      currentPosition: pos,
      posts: []
    );
  }
}