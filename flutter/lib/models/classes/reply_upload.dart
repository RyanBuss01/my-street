import 'dart:io';

class ReplyUpload {
  int? id;
  int postId;
  bool isUploaded;
  String? msg;
  String? media;
  File? file;
  int? index;

  ReplyUpload({
    this.id,
    required this.isUploaded,
    required this.postId,
    this.msg,
    this.media,
    this.file,
    this.index
});

}