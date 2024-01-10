class Reply {
  final int id;
  final int userId;
  final int postId;
  final String? msg;
  final String? media;
  final int? replyTo;

  Reply({required this.id, required this.userId, required this.postId,  this.media,  this.msg, this.replyTo});

  static Reply fromDoc(dynamic json) {
    return Reply(
        id: json['reply_id'],
        userId: json['user_id'],
        postId: json['post_id'],
        media: json['liveReplyMedia'],
        msg: json['msg'],
        replyTo: json['replyTo']
    );
  }

}