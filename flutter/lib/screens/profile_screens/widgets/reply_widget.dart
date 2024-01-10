import 'package:flutter/material.dart';

import '../../../models/classes/reply.dart';
import '../../../models/classes/reply_upload.dart';

class ReplyWidget extends StatefulWidget {
  final bool isMe;
  final Reply? reply;
  final ReplyUpload? upload;
  const ReplyWidget(this.reply, {Key? key, this.isMe = false, this.upload}) : super(key: key);

  @override
  State<ReplyWidget> createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
    widget.reply != null ? CircleAvatar(
          radius: 60,
          backgroundImage:  NetworkImage(widget.reply!.media!),
        ) : widget.upload != null
        ? CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(widget.upload!.file!),
    ) :
    CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[700],
    )

      ],
    );
  }
}
