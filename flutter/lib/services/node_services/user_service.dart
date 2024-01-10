import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../models/classes/myUser.dart';
import '../../models/classes/user.dart';
import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';

class UserService {

  Future<User> getUserdata(int? id, {isMe = false, isProfilePage = false, String? username}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getUserdata'),
        headers: {
          'id': id.toString(),
          'isme' : isMe.toString(),
          'myId' : isMe ? '' :  user.id.toString(),
          'username' : username ?? '',
          'querytype' : username == null ? 'byId' : 'byUsername'
        }
    );
    var json = await jsonDecode(res.body);
    return User.fromDoc(json, isMe: isMe, isProfilePage: isProfilePage);
  }

  Future<MyUser> getMyUserdata(int? id, {isMe = false, isProfilePage = false, String? username, required Position pos}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getUserdata'),
        headers: {
          'id': id.toString(),
          'isme' : isMe.toString(),
          'myId' : isMe ? '' :  user.id.toString(),
          'username' : username ?? '',
          'querytype' : username == null ? 'byId' : 'byUsername'
        }
    );
    var json = await jsonDecode(res.body);
    return MyUser.fromDoc(json, isMe: isMe, isProfilePage: isProfilePage, pos: pos);
  }

  Future<http.Response> attemptSignUp({required String email, required String password, required String firstName, required String lastName, required String displayName, required String username, required DateTime birthday}) async {
    print( birthday.toString());
    var res = await http.post(
        Uri.http(baseUrl, '/signup'),
        body: {
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
          "username" : username,
          "displayName": displayName,
          "birthday": birthday.toString()
        }
    );

    return res;
  }

  Future<http.Response> attemptLogIn(String email, String password) async {
    var res = await http.post(
        Uri.http(baseUrl, '/signin'),
        body: {
          "email": email,
          "password": password
        }
    );
    return res;
  }



  Future removeFriend(User userdata) async {
    var res = await http.delete(
        Uri.http(baseUrl, '/removeFriend'),
        headers: {
          'id': userdata.id.toString(),
          'myid' : user.id.toString(),
        }
    );
    return res;
  }

  Future blockUser(User userdata) async {
    var res = await http.post(
        Uri.http(baseUrl, '/blockUser'),
        body: {
          "myId": user.id.toString(),
          "altId": userdata.id.toString(),
        }
    );
    return res.statusCode;
  }

  Future<int> unBlockUser(int altId) async {
    var res = await http.delete(
        Uri.http(baseUrl, '/unblockUser'),
        headers: {
          "myId": user.id.toString(),
          "altId" : altId.toString()
        }
    );

    return res.statusCode;
  }

  Future getBlockedUser(int id, {int chunkSet = 0}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/getBlockedUsers'),
        headers: {
          "id": id.toString(),
          'chunkset' : chunkSet.toString()
        }
        );

    List<User> usersList = (jsonDecode(res.body) as List).map((data) => User.fromDoc(data)).toList();

    return usersList;
  }


}