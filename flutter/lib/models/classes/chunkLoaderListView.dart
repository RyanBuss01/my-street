import 'package:flutter/material.dart';
import '../../services/node_services/user_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/classes/comment.dart';
import '../../screens/frame.dart';
import '../../screens/map_screens/classes/filter_feed.dart';
import '../../services/node_services/friend_service.dart';
import '../../services/node_services/search_service.dart';
import '../classes/loader.dart';
import '../classes/user.dart';

typedef ChuckLoaderBuilder = Widget Function(
    BuildContext context,
    AsyncSnapshot snap,
    Loader loader,
    );


class ChunkLoader extends StatefulWidget {
  final FilterFeed? filters;
  final String? tag;
  final String futureKey;
  final bool resetState, isDefault;
  final double zoom;
  final double latitude;
  final double longitude;
  final Function? callback;
  final User? userdata;
  final int? id;
  final ChuckLoaderBuilder builder;
  final ScrollController? parentController;
  final String? searchText;

  const ChunkLoader({Key? key,
    required this.builder,
    required this.futureKey,
    this.tag,
    this.filters,
    this.resetState = false,
    this.isDefault = false,
    this.zoom = 0,
    this.latitude = 0,
    this.longitude = 0,
    this.callback,
    this.userdata,
    this.parentController,
    this.searchText,
    this.id
  }) : super(key: key);

  @override
  State<ChunkLoader> createState() => _ChunkLoaderState();
}

class _ChunkLoaderState extends State<ChunkLoader> {
  late FilterFeed? filters = widget.filters;
  late String futureKey = widget.futureKey;
  int chunkSet = 1;
  bool willDuplicate = false;

  late Loader loader;

  late Future _future;


  Future queryPosts() async {
    if(futureKey == 'overlayPosts') {
      // return await GeoPostService.getFeedPosts(
      //     widget.zoom,
      //     widget.latitude,
      //     widget.longitude,
      //     chunkSet
      // );
    }
    if(futureKey == 'friend') {
      return await FriendsService().getFriendsList(user.id);
    }
    if(futureKey == 'request') {
      return await FriendsService().getFriendRequestList(user.id, chunkSet: chunkSet);
    }
    if(futureKey == 'blocked') {
      return await UserService().getBlockedUser(user.id, chunkSet: chunkSet);
    }
    if(futureKey == 'user') {
      return await SearchService().getUserSearchQuery(widget.searchText!, chunkSet: chunkSet);
    }
  }


  Future runFuture({changeOffset = true}) async {
    if (chunkSet != 1 && !loader.isLimitReached) {
      setState(() => loader.isQuerying = true);
    }
    if (!loader.isLimitReached) {
      if(futureKey == 'friend' || futureKey == 'request' || futureKey == 'blocked') {
        List<User> usersList = await queryPosts();
        loader.users.addAll(usersList);
        List<int> ids = usersList.map((e) => e.id).toList();
        var contain = loader.users.where((e) => ids.contains(e.id));
        if (contain.isNotEmpty) {
          loader.isLimitReached = true;
        } else {
          loader.users.addAll(usersList);
          if(changeOffset) {
            chunkSet++;
          }
          return loader.users;
        }

      }

      if(futureKey == 'userSearch') {
        List<User> usersList = await queryPosts();
        loader.users.addAll(usersList);
        List<int> ids = usersList.map((e) => e.id).toList();
        var contain = loader.users.where((e) => ids.contains(e.id));
        if (contain.isNotEmpty) {
          loader.isLimitReached = true;
        } else {
          loader.users.addAll(usersList);
          if(changeOffset) {
            chunkSet++;
          }
          return loader.users;
        }
      }
    }
  }


  @override
  void didUpdateWidget(covariant ChunkLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(widget.resetState) {
      if(widget.futureKey == 'hashTag') {
        applySettings();
      }
    }
  }

  applySettings() {
    chunkSet = 1;
    loader.isLimitReached = false;
    filters = widget.filters;
    loader.posts = [];
    _future = runFuture();
  }

  commentPostCallback(CommentModel comment) {
     loader.scrollController.jumpTo(0);
     loader.comments.insert(0, comment);
     setState(() {});
  }

  addComment(CommentModel comment) {
    loader.scrollController.jumpTo(0);
    loader.comments.insert(0, comment);
    setState(() {});
  }

  commentRefreshCallback() {
    loader.comments = [];
    chunkSet = 1;
    _future = runFuture();
    setState(() {});
  }

  _scrollListener() {

    if (loader.scrollController.offset >= loader.scrollController.position.maxScrollExtent - 400 &&  !loader.isQuerying && !loader.isLimitReached) {
      loader.isQuerying = true;
      runFuture().then((value) {
        setState(() => loader.isQuerying = false);
      });
    }
  }

  _itemListener() {
    final visiblePosts = loader.itemListener.itemPositions.value.map((e) => e.index).toList();
    final int i = (futureKey == 'profile' ?
    loader.posts.length - 1
        : loader.posts.length - 3);
    if(visiblePosts.contains(i)) {
      loader.isQuerying = true;
      runFuture().then((value) {
        setState(() => loader.isQuerying = false);
      });
    }
  }


    @override
    initState()  {
      loader = Loader(
          futureKey: widget.futureKey,
          users: [],
          posts: [],
          comments: [],
          itemListener: ItemPositionsListener.create(),
          itemController: ItemScrollController(),
          scrollController: (widget.parentController != null) ?  widget.parentController! : ScrollController(),
          commentRefreshCallback: commentRefreshCallback
      );

      super.initState();
      _future = runFuture();
      if(futureKey == 'friend' || futureKey == 'request' || futureKey == 'blocked' || futureKey == 'postComments') {
        loader.scrollController.addListener(_scrollListener);
      }
      if(futureKey == 'overlayPosts' || futureKey == 'hashTag' || futureKey == 'profile') {
        loader.itemListener.itemPositions.addListener(_itemListener);
      }
    }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
          future: _future,
          builder: (context, snap) {
            return widget.builder(
                context,
                snap,
                loader,
            );
          }
      );
  }
}


