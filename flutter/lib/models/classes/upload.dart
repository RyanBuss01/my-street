import 'dart:io';

class Upload {
  final String localId;
  String status;
  final File? media;
  String? mediaUrl;
  final String? caption;
  final String type;
  final String contentType;
  List<String>? tags;
  List<String>? ats;
  List<int>? storyIds;

  Upload({required this.localId, this.media, this.caption, required this.status, required this.type, required this.mediaUrl, this.ats, this.tags, required this.contentType, this.storyIds});
}