import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/classes/post.dart';
import '../../../models/classes/reply_upload.dart';
import '../../../services/node_services/post_service.dart';

import '../../../models/classes/reply.dart';
import '../../../models/universal_widgets/live_reply_widget.dart';
import '../../frame.dart';


class ProfilePostPage extends StatefulWidget {
  final Post post;
  final Function callback;
  const ProfilePostPage(this.post, {Key? key, required this.callback}) : super(key: key);

  @override
  State<ProfilePostPage> createState() => _ProfilePostPageState();
}

class _ProfilePostPageState extends State<ProfilePostPage> with TickerProviderStateMixin {
  late Post post = widget.post;


  final TextEditingController _controller = TextEditingController();
  late FocusNode myFocusNode = FocusNode();

  String? _commentText, _captionText;
  bool _liveVisible = false,  ready = false, _editCaption = false;
  ReplyUpload? upload;

  late Reply? myReply = widget.post.myReply;


  uploadLiveReply(File? file) {
    upload = ReplyUpload(isUploaded: true, postId: post.id, file: file, id: myReply?.id, msg: _commentText);
    PostService.uploadLiveReply(upload!).then((value) => setState(() {
      myReply = value;
      upload = null;
    }));
    setState(() {
      if(_liveVisible) {
        closeLiveReply();
      }
      _commentText = null;
      _controller.clear();
    });
  }

  closeLiveReply() {
    _liveVisible = false;
      widget.callback(true);

  }

  uploadPostCaption() {
    PostService.uploadPostCaption(_captionText!, post);
    setState(() {
      post.caption = _captionText!;
      _editCaption = false;
    });
  }


  showLiveReply() {
    _liveVisible = true;
    widget.callback(false);
  }



  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Stack(
        children: [
          postListView(),
          // liveReplyScreen(),
          // file != null ? replyScreen() : const SizedBox(),
          LiveReplyWidget(
            liveVisible: _liveVisible,
            onClose: () => setState(() {_liveVisible = false; widget.callback(true);}),
            onUpload: (File file) => uploadLiveReply(file),
          ),

        ],
      ),
    );
  }

  Widget postListView() {
    return ListView(
      primary: _liveVisible,
      children: [
        imageWidget(),
        post.userId != user.id ? captionWidget() : const SizedBox(),
        post.userId == user.id ? createCaptionWidget() : myReplyWidget(),
      ],
    );
  }

  Widget imageWidget() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image(
            image: NetworkImage(post.media),
            fit: BoxFit.fitWidth,
            loadingBuilder: (context, Widget child, ImageChunkEvent? progress) {
              if(progress == null) { return child; }
              else {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * (4/3),
                  color: Colors.grey[800],
                );
              }
            },
          ),
        ),
        post.userId != user.id ? Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => setState(() {
              showLiveReply();
            }),
            child: myReply?.media != null
                ? const SizedBox()
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
        ) : const SizedBox()
      ],
    );
  }

  Widget captionWidget() {
    return post.caption != null ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Text(
        post.caption!,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ) : const SizedBox();
  }

  Widget createCaptionWidget() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child:
                post.caption != null && _editCaption == false ?
            Text(
              post.caption!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )

                : TextField(
              controller: _controller,
              focusNode: myFocusNode,
              maxLines: 10,
              minLines: 1,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  focusColor: Colors.white,
                  hintText: 'Write a Caption',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  hoverColor: Colors.white,
                  enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!, width: 2)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 3))
              ),
              onChanged: (val) {
                if(val == '') {
                  setState(() => _captionText = null);
                }
                else {
                  setState(() => _captionText = val);
                }
              },
            ),
          ),
        ),
        post.caption == null || _editCaption ? Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_upward,
              size: 30,
            ),
            color: _captionText == null ? Colors.grey : Colors.lightBlue[400],
            onPressed: () {
              uploadPostCaption();
            },
          ),
        ) : Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            icon: const Icon(
              CupertinoIcons.pencil,
              size: 20,
            ),
            color: Colors.grey,
            onPressed: () => setState(() {
              _controller.text = post.caption ?? '';
              _editCaption = true;
              myFocusNode.requestFocus();
            }),
          ),
        )
      ],
    );
  }

  Widget myReplyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      child: Row(
        children: [
          myReply?.media != null ? CircleAvatar(
            radius: 50,
            backgroundImage:  NetworkImage(myReply!.media!),
          ) : upload?.media != null
              ? CircleAvatar(
            radius: 50,
            backgroundImage: FileImage(upload!.file!),
          ) : const SizedBox(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: upload != null ?
              LinearProgressIndicator(color: Colors.grey[700],)
                  : myReply?.msg != null ?

              Text(
                myReply!.msg!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )

                  : TextField(
                controller: _controller,
                maxLines: 10,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    focusColor: Colors.white,
                    hintText: 'Leave a comment',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    hoverColor: Colors.white,
                    enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!, width: 2)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 3))
                ),
                onChanged: (val) {
                  if(val == '') {
                    setState(() => _commentText = null);
                  }
                  else {
                    setState(() => _commentText = val);
                  }
                },
              ),
            ),
          ),
          myReply?.msg == null ? Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_upward,
                size: 30,
              ),
              color: _commentText == null ? Colors.grey : Colors.lightBlue[400],
              onPressed: () {
                uploadLiveReply(null);
              },
            ),
          ) : const SizedBox()
        ],
      ),
    );
  }





}





