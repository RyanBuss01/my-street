import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../models/classes/post.dart';
import '../../models/classes/comment.dart';
import '../../models/classes/user.dart';
import '../../models/constants/base_url.dart';
import '../../screens/map_screens/markers/geo_post_marker.dart';
import '../../screens/map_screens/markers/my_user_marker.dart';
import '../../screens/map_screens/markers/user_marker.dart';
import '../../screens/frame.dart';
import '../internal_services/map_service.dart';

class GeoPostService {

  Future<int> uploadGeoPost(String? postCaption, String? imageUrl, String contentType, List<String> tags, List<String> ats) async {
    List<String> tagList = [];
      for (String tag in tags) {
        tagList.add(tag.substring(1));
      }
    List<String> atsList = [];
    for (String at in ats) {
      atsList.add(at.substring(1));
    }

        var res = await http.post(
            Uri.http(baseUrl, '/uploadGeoPost'),
            body: {
              'userId': user.id.toString(),
              'caption': postCaption ?? '',
              'longitude': user.currentPosition.longitude.toString(),
              'latitude': user.currentPosition.latitude.toString(),
              'contentType': contentType,
              "media": imageUrl ?? '',
              'hasTags' : tags.isNotEmpty ? 'true' : 'false',
              'tags' : tagList.toString(),
              'hasUserTags' : atsList.isNotEmpty ? 'true' : 'false',
              'userTags' : atsList.toString()
            }
        );

        return res.statusCode;
    }


  static Future<int> uploadCommentToPost(int postId, int userId, String message, List<String> ats, List<String> tags) async {

    List<String> tagList = [];
    for (String tag in tags) {
      tagList.add(tag.substring(1));
    }
    List<String> atsList = [];
    for (String at in ats) {
      atsList.add(at.substring(1));
    }

    var res = await http.post(
        Uri.http(baseUrl, '/uploadGeoPostComment'),
        body: {
          'userId' : userId.toString(),
          'postId' : postId.toString(),
          'message' : message,
          'hasTags' : tags.isNotEmpty ? 'true' : 'false',
          'tags' : tagList.toString(),
          'hasUserTags' : atsList.isNotEmpty ? 'true' : 'false',
          'userTags' : atsList.toString()
        }
    );

    return int.parse(res.body);
  }

  static getPostComments({required int postId, required int chunkSet}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getPostComments'),
        headers: {
          'postid' : postId.toString(),
          'userid' : user.id.toString(),
          'chunkSet' : chunkSet.toString()
        }
    );

    List<CommentModel> comments = (jsonDecode(res.body) as List)
        .map((e) => CommentModel.fromDoc(e)).toList();


    return comments;
  }

  static likeComment(bool isLiked, int commentId, int postId) async {
    var res = await http.post(
        Uri.http(baseUrl, '/likeGeoPostComment'),
        body: {
          'isLiked' : isLiked.toString(),
          'commentId' : commentId.toString(),
          'postId' : postId.toString(),
          'userId' : user.id.toString()
        }
    );
    return res;
  }







  static Future reportPost(int postId) async {
    var res = await http.post(
        Uri.http(baseUrl, '/reportPost'),
        body: {
          'postId' : postId.toString(),
          'userId': user.id.toString(),
        }
    );
  }
}