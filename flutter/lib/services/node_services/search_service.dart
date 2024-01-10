import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/classes/user.dart';
import '../../models/constants/base_url.dart';
import '../../screens/frame.dart';


class SearchService {

  Future<List> getSearchQuery(String searchText) async {

    var res = await http.get(
        Uri.http(baseUrl, '/search'),
        headers: {
          'userId' : user.id.toString(),
          'search': searchText
        }
    );

    List<User> usersList = (jsonDecode(res.body)['users'] as List)
        .map((data) => User.fromDoc(data)).toList();


    return [usersList];
  }

  Future<List<User>> getUserSearchQuery(String searchText, {bool isCaption = false, int chunkSet = 0, bool getFriends = false}) async {
    var res = await http.get(
        Uri.http(baseUrl, '/userSearch'),
        headers: {
          'userId' : user.id.toString(),
          'search': searchText,
          'chunkset' : chunkSet.toString(),
          'getFriends' : getFriends.toString()
        }
    );
    List<User> usersList = (jsonDecode(res.body)['users'] as List)
        .map((data) => User.fromDoc(data)).toList();

    return usersList;
  }


  static Future<List<User>> getStoryUserSearchQuery(String searchText, int storyId, String type) async {
    var res = await http.get(
        Uri.http(baseUrl, '/userStorySearch'),
        headers: {
          'userId' : user.id.toString(),
          'search': searchText,
          'storyId' : storyId.toString(),
          'type' : type.toString()
        }
    );
    List<User> usersList = (jsonDecode(res.body) as List)
        .map((data) => User.fromDoc(data, selectType: type)).toList();

    return usersList;
  }

}