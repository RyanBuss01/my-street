import 'dart:io';

import '../../models/classes/upload.dart';
import '../../screens/frame.dart';
import 'package:uuid/uuid.dart';

import '../node_services/geo_post_service.dart';
import 'image_service.dart';

class UploadService {

  static uploadHandler({required bool isMapPostSelected, required List<int> selectedStories, required String contentType, File? file, String? caption, List<String>? tags, List<String>? ats}) async {
    List<Upload> uploads = [];
    int? statusCode;

    if(isMapPostSelected)  {
      Upload upload = Upload(
        localId: const Uuid().v4(),
        media: file,
        caption: caption,
        status: 'loading',
        type: 'geoPost',
        mediaUrl: null,
        ats: ats ?? [],
        tags: tags ?? [],
          contentType: contentType
      );
      uploads.add(upload);
      user.uploads.add(upload);
    }

    if(selectedStories.isNotEmpty) {
      Upload upload = Upload(
          localId: const Uuid().v4(),
        media: file,
        caption: caption,
        status: 'loading',
        type: 'storyPost',
        mediaUrl: null,
        contentType: contentType,
        storyIds: selectedStories
      );

      uploads.add(upload);
      user.uploads.add(upload);
    }

    String? url;

    if(file != null) {
      url = await ImageService.upload(file)
          .onError((error, stackTrace) {
        statusCode = 400;
            return '';
      });
    }

    for (Upload u in uploads) {
      int i = user.uploads.indexWhere((e) => e.localId == u.localId);

      user.uploads[i].mediaUrl = url;

      if(statusCode == null) {
        if (u.type == 'geoPost') {
          statusCode = await GeoPostService().uploadGeoPost(
              u.caption, u.mediaUrl, contentType, tags ?? [], ats ?? []);
        }
      }

      if(statusCode == 200) {
        user.uploads[i].status = 'complete';
      }
      else {
        user.uploads[i].status = 'error';
      }
    }
  }

  static uploadRetry(Upload upload) async {
    int i = user.uploads.indexWhere((e) => e.localId == upload.localId);
    int? statusCode;
    String? url;

    user.uploads[i].status = 'loading';

    if(upload.media != null) {
      url = await ImageService.upload(upload.media!)
          .onError((error, stackTrace) {
        statusCode = 400;
        return '';
      });
    }
      user.uploads[i].mediaUrl = url;

      if(statusCode == null) {
        if (upload.type == 'geoPost') {
          statusCode = await GeoPostService().uploadGeoPost(
              upload.caption, upload.mediaUrl, upload.contentType, upload.tags ?? [], upload.ats ?? []);
        }
      }

      if(statusCode == 200) {
        user.uploads[i].status = 'complete';
      }
      else {
        user.uploads[i].status = 'error';
      }
  }
}