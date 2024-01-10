import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../../models/classes/post.dart';
import '../../models/classes/reply.dart';
import '../../models/classes/reply_upload.dart';

import '../../models/classes/place.dart';
import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';
import '../internal_services/image_service.dart';


class PostService {
  static Future<int> uploadGeoPost({required File imageFile, required String type}) async {
    String url = await ImageService.upload(imageFile);

    var res = await http.post(
        Uri.http(baseUrl, '/uploadPost'),
        body: {
          'userId': user.id.toString(),
          'longitude': user.currentPosition.longitude.toString(),
          'latitude': user.currentPosition.latitude.toString(),
          'type': type,
          "media": url,

        }
    );

    return res.statusCode;
  }


  static Future<List<Post>> getUserPosts(int id) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getUserPosts'),
        headers: {
          'id' : id.toString(),
          'myId' : user.id.toString()
        }
    );

    List<Post> posts = (jsonDecode(res.body) as List).map((data) =>  Post.fromDoc(data)).toList();

    return posts;
  }

  static Future<List<Post>> getMyUserPosts() async {
    var res = await http.get(
        Uri.http(baseUrl, '/getUserPosts'),
        headers: {
          'id' : user.id.toString(),
          'myId' : user.id.toString()
        }
    );

    List<Post> posts = (jsonDecode(res.body) as List).map((data) =>  Post.fromDoc(data)).toList();
    user.posts = posts;
    return posts;
  }

  static Future<Reply> uploadLiveReply(ReplyUpload upload) async {
    String? url;
    if(upload.file!= null) {
      url = await ImageService.upload(upload.file!);
    }



    var res = await http.post(
        Uri.http(baseUrl, '/uploadLiveReply'),
        body: {
          'userId': user.id.toString(),
          'postId' : upload.postId.toString(),
          'replyId' : upload.id.toString(),
          'msg' : upload.msg.toString(),
          'media': url.toString(),
        }
    );

    Reply reply = (jsonDecode(res.body) as List).map((data) =>  Reply.fromDoc(data)).toList()[0];

    return reply;
  }

  static Future uploadPostCaption(String caption, Post post) async {
    var res = await http.post(
        Uri.http(baseUrl, '/uploadPostCaption'),
        body: {
          'caption' : caption,
          'userId': user.id.toString(),
          'postId' : post.id.toString(),
        }
    );

    return res.statusCode;
  }

  static Future<List<Post>> overlayPosts({required double zoom, required double latitude, required double longitude}) async {


    var res = await http.get(
        Uri.http(baseUrl, '/getOverlayPosts'),
        headers: {
          'zoom' : zoom.toString(),
          'userid' : user.id.toString(),
          'latitude' : latitude.toString(),
          'longitude' : longitude.toString(),
        }
    );


    List<Post> posts = (jsonDecode(res.body) as List).map((data) =>  Post.fromDoc(data, getUser: true)).toList();
    return posts;
  }

  static Future<List<Post>> placePosts(Place place) async {


    var res = await http.get(
        Uri.http(baseUrl, '/getOverlayPosts'),
        headers: {
          'userid' : user.id.toString(),
          'latitude' : place.lat.toString(),
          'longitude' : place.long.toString(),
        }
    );


    List<Post> posts = (jsonDecode(res.body) as List).map((data) =>  Post.fromDoc(data, getUser: true)).toList();
    return posts;
  }

}