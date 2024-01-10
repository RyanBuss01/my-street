import 'package:flutter/material.dart';
import '../../models/classes/post.dart';
import '../../models/classes/user.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'comment.dart';

class Loader {
  final String futureKey;
  List<User> users;
  List<Post> posts;
  List<CommentModel> comments;
  bool isLimitReached;
  bool isQuerying;
  final ItemScrollController itemController;
  final ItemPositionsListener itemListener;
  final ScrollController scrollController;
  final Function commentRefreshCallback;

  Loader({
    required this.futureKey,
    required this.users,
    required this.posts,
    required this.comments,
    this.isLimitReached = false,
    this.isQuerying = false,
    required this.itemController,
    required this.itemListener,
    required this.scrollController,
    required this.commentRefreshCallback
  });
}