import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../screens/map_screens/widgets/post_card.dart';
import '../../services/node_services/post_service.dart';


import '../../models/classes/place.dart';
import '../../models/classes/post.dart';
import '../../models/classes/reply_upload.dart';
import '../../models/classes/user.dart';
import '../../models/universal_widgets/live_reply_widget.dart';

class OverlayScreen extends StatefulWidget {
  final Function callback;
  final Post? post;
  final List<User>? users;
  final bool isMe;
  final double zoom;
  final double latitude;
  final double longitude;
  final Place? place;
  const OverlayScreen({Key? key, required this.callback, required this.post,  this.users, this.isMe = false, required this.zoom, required this.latitude, required this.longitude, required this.place}) : super(key: key);

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  late bool isMe = widget.isMe;
  Future? _postsFuture;

  List<User> users = [];
  bool isAtTagging = false, canPop = true, isMuted = true, _liveVisible = false;
  List<int> visiblePosts = [];
  List<Post> posts = [];
  int playableIndex = 0;
  int? selectedPostIndex;


  RegExp regHash = RegExp(r"\B#[a-zA-Z0-9]+\b");
  RegExp regAt = RegExp(r"\B@[a-zA-Z0-9]+\b");


  Future getOverlayPosts() async {
    if(widget.place != null) {
      posts = await PostService.placePosts(widget.place!);
    }
    else {
      posts = await PostService.overlayPosts(
          zoom: widget.zoom,
          longitude: widget.longitude,
          latitude: widget.latitude);
    }
    return posts;
  }

  uploadLiveReply(File? file) {
    ReplyUpload upload = ReplyUpload(isUploaded: true, postId: posts[selectedPostIndex!].id, file: file, id: posts[selectedPostIndex!].myReply?.id, index: selectedPostIndex!);
    PostService.uploadLiveReply(upload).then((value) => setState(() {
      posts[upload.index!].myReply = value;
    }));
        closeLiveReply();
  }

  closeLiveReply() {
    setState(() { selectedPostIndex = null; _liveVisible = false;});
  }

  showLiveReply(int index) {
    setState(() => selectedPostIndex = index);
    _liveVisible = true;

  }


  @override
  initState() {
    users = widget.users ?? [];
    _postsFuture = getOverlayPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: geoPostListBuilder(),
      ),
    );
  }

  Widget geoPostListBuilder() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {

        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
        child: Stack(
          children: [
            overlayListView(),
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0, right: 20),
                child: Align(
                  alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => widget.callback(),
                      child: Container(
                        decoration:  BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.8),
                          shape: BoxShape.circle
                        ),
                          child: const Padding(
                            padding:  EdgeInsets.all(5.0),
                            child:  Icon(
                              Icons.close, size: 35,
                              color: Colors.white,),
                          )
                      ),
                    )
                ),
              ),
            ),
            LiveReplyWidget(
              liveVisible: _liveVisible,
              onClose: () => setState(() => closeLiveReply()),
              onUpload: (File file) => uploadLiveReply(file),
            ),
          ],
        )
      // ),
    );
  }

  Widget overlayListView() {
    return FutureBuilder(
      future: _postsFuture,
      builder: (context, snap) {
        if(snap.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: posts.length,
              physics: selectedPostIndex == null ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return PostCard(posts[index],
                  liveReplyCallback: () => setState(() => showLiveReply(index)),
                );
              }
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }

}

