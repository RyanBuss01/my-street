import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../models/constants/base_url.dart';

class ImageService {

  static Future<File?> getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 25
    );

    if(pickedFile != null) { return File(pickedFile.path) ;}
    else {return null;}
  }

  static Future<String> upload(File imageFile) async {

    // open a bytestream
    var stream = http.ByteStream(imageFile.openRead());

    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("http://$baseUrl/uploadImage");

    // create multipart request
    var request = http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = http.MultipartFile('myFile', stream.cast(), length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();

    //get response body
    var responded = await http.Response.fromStream(response);


    return responded.body;

  }
}