import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/classes/user.dart';
import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';


class FriendsService {
  Future<List<User>> getFriendsList(int id, {int chunkSet = 0}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getFriendsList'),
        headers: {
          'myid' : id.toString(),
          'chunkset' : chunkSet.toString()
        }
    );

    List<User> friendsList = (jsonDecode(res.body) as List)
        .map((data) => User.fromDoc(data)).toList();

    return friendsList;
  }

  Future<List<User>> getFriendRequestList(int id, {int chunkSet = 0}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getFriendRequestList'),
        headers: {
          'myid' : id.toString(),
          'chunkSet' : chunkSet.toString()
        }
    );

    List<User> friendsList = (jsonDecode(res.body) as List)
        .map((data) => User.fromDoc(data)).toList();

    return friendsList;
  }

  // Future<List<User>> getRequestsList(List<String> requestsIds) async {
  //   var res = await http.get(
  //       Uri.http(baseUrl, '/getUsersList'),
  //       headers: {
  //         'myid' : user.id.toString(),
  //         'altid' :
  //       }
  //   );
  //
  //   List<User> friendsList = (jsonDecode(res.body) as List)
  //       .map((data) => User.fromDoc(data)).toList();
  //
  //   return friendsList;
  // }

  Future<int> addFriend(User altUser, {String? forcedStatus}) async{
    var res = await http.post(
        Uri.http(baseUrl, '/addFriend'),
        body: {
          'myId' : user.id.toString(),
          'altId' : altUser.id.toString(),
          'status' : forcedStatus ?? altUser.friendStatus
        }
    );

    return res.statusCode;
  }

  Future<int> removeRequest(User altUser) async {
    var res = await http.post(
        Uri.http(baseUrl, '/removeRequest'),
        body: {
          'myId' : user.id,
          'altId' : altUser.id,
        }
    );

    return res.statusCode;
  }
}