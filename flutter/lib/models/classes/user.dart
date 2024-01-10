import '../../screens/frame.dart';
import 'myUser.dart';

class User {
  final int id;
  final String displayName;
  final String username;
  final String? bio;
  final String avatar;
  final String friendStatus;
  final bool isFriend;
  final bool isMe;
  final int? mainStoryId;
  final int? userCount;
  final int? postCount;
  final double? latitude;
  final double? longitude;
  final DateTime? timestamp;
  bool? isSelected;


  User({
    required this.id,
    required this.displayName,
    required this.username,
    this.bio,
    required this.avatar,
    required this.friendStatus,
    required this.isFriend,
    required this.isMe,
    this.mainStoryId,
    this.userCount,
    this.postCount,
    this.latitude,
    this.longitude,
    this.timestamp,
    this.isSelected,
  });


  factory User.fromDoc(dynamic json, {isProfilePage = false, isMe = false, int? count, String? selectType}) {
    return User(
        id: json['user_id'] ?? json['id'],
        displayName: json['displayName'],
        username: json['displayName'],
        bio: isProfilePage || isMe ? json['bio'] : null,
        avatar: json['avatar'],
        friendStatus: isMe
            ? 'isMe'
            : json['friend_status'] == 'friend' ? 'friend'
            : json['receiver'] == user.id ? 'receiver'
            : json['sender'] == user.id ? 'sender'
            : 'none',
        isFriend: json['friend_status'] == 'friend' ? true : false,
        isMe: isMe ? true : false,
        mainStoryId: json['story_id'],
        userCount: count,
        latitude: json['latitude'],
        longitude: json['longitude'],
        timestamp: json['dt']!= null ? DateTime.parse(json['dt'].toString()) : null,
      isSelected: ((selectType == 'view' && json['canPost'] != null) || (selectType == 'post' && json['canPost'] == 1)) ? true : false,
    );
  }

  static User addCounts(User userdata, int? postCount) {
    return User(
        id: userdata.id,
        displayName: userdata.displayName,
        username: userdata.username,
        avatar: userdata.avatar,
        friendStatus: userdata.friendStatus,
        isFriend: userdata.isFriend,
        isMe: userdata.isMe,
        latitude: userdata.latitude,
        longitude: userdata.longitude,
        userCount: userdata.userCount,
        postCount: postCount,
    );
  }

  static User fromMsgDoc(dynamic json) {
    return User(
        id: json['msg_user_id'],
        displayName: json['msg_displayName'],
        username: json['msg_username'],
        avatar: json['msg_avatar'],
        friendStatus: 'none',
        isFriend: false,
        isMe: false
    );
  }


  static User parse(dynamic data) => User.fromDoc(data['displayUser'], count: data['count']);

  static fromMyUser(MyUser myUser, {double? latitude, double? longitude}) {
    return User(
        id: myUser.id,
        displayName: myUser.displayName,
        username: myUser.username,
        avatar: myUser.avatar,
        friendStatus: 'isMe',
        isFriend: false,
        isMe: true,
        latitude: latitude,
        longitude: longitude
    );
  }

  static User fromMinDoc(dynamic json) {
    return User(
      id: json['user_id'] ?? json['id'],
      displayName: json['displayName'],
      username: json['username'],
      avatar: json['avatar'],
      friendStatus: '',
      isFriend: true,
      isMe: false,
    );
  }

}