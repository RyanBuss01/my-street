import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/classes/post.dart';

import '../../frame.dart';
import '../../profile_screens/profile_screen.dart';

class PostCard extends StatefulWidget {
  final Function liveReplyCallback;
  final Post post;
  PostCard(this.post, {Key? key, required this.liveReplyCallback}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post post = widget.post;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(userId: post.userId,))),
                          child: CircleAvatar(backgroundImage: NetworkImage(post.user!.avatar), radius: 30)
                      ),
                      const SizedBox(width: 15,),
                      Text(post.user!.displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: (MediaQuery.of(context).size.width - 40) * (4/3),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                      image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: NetworkImage(post.media)
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
        post.userId != user.id ? Positioned(
          bottom: 15,
          right: 25,
          child: Column(
            children: [

              GestureDetector(
                onTap: () => setState(() {
                  widget.liveReplyCallback();
                }),
                child: post.myReply?.media != null
                    ? const SizedBox() /// show image
                    : Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey)
                        ),
                        child: const Icon(CupertinoIcons.bolt, color: Colors.white,),
                      ),
              ),
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }
}
