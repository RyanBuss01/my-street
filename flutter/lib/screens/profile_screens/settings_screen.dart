import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../screens/profile_screens/users_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/classes/myUser.dart';
import '../../models/constants/base_url.dart';
import '../../models/custom_classes/overlay_class.dart';
import '../../models/universal_widgets/close_button.dart';
import '../../services/internal_services/image_service.dart';
import '../../services/internal_services/navigation_service.dart';
import '../authenticate/wrapper.dart';
import '../frame.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _avatarImageFile;
  bool _canApply = false;
  bool _changeDisplayName = false;
  bool _changeBio = false;
  bool _showOverlay = false;
  final TextEditingController _displayNameController = TextEditingController(text: user.displayName);
  final TextEditingController _bioController = TextEditingController(text: user.bio);


  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('signedIn', false);
    prefs.remove('id');
    NavigationService.pushReplacement(context, const Wrapper());
  }

  applySettings() async {
    String? avatarUrl;
    if(_avatarImageFile != null) {
      avatarUrl = await ImageService.upload(_avatarImageFile!);
    }
   var res = await http.post(
         Uri.http(baseUrl, '/updateUserData'),
         body: {
           "id" : user.id.toString(),
           "bio" : _changeBio ? _bioController.text : '',
           "displayName" :  _changeDisplayName ? _displayNameController.text : '',
           "avatar" : avatarUrl ?? ''
         }
     );

    if(res.statusCode == 200) {
      user = MyUser.fromDoc(await jsonDecode(res.body), isMe: true, pos: user.currentPosition);
      Navigator.pop(context);
    }
  }

  _getFromGallery() async {
    File? file = await ImageService.getFromGallery();
    if (file != null) {
      setState(() {
        _avatarImageFile = file;
        _canApply = true;
      });
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
          style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              color: Colors.grey,
              height: 1,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: OverlayClass(
          backgroundTouchCallback: () {
            setState(() {
              _showOverlay = false;
            });
          },
          overlay: overlayLogOutWidget(),
          show: _showOverlay,
          child: ListView(
            cacheExtent: 10000,
            children: [
              const SizedBox(height: 20,),
               Center(
                child: GestureDetector(
                  onTap: () {
                    _getFromGallery();
                  },
                  child : SizedBox(
                    height: 100,
                    width: 100,
                    child: ClipOval(
                      child: _avatarImageFile != null ? Image.file(_avatarImageFile!, fit: BoxFit.cover,)
                      : Image(
                        image: NetworkImage(user.avatar),
                        fit: BoxFit.cover,
                      )
                    ),
                  )
                ),
              ),
              const SizedBox(height: 20,),
              textEditField('displayName'),
              textEditField('bio'),
              blockedUsersWidget(),
              const SizedBox(height: 20,),
              Center(
                child: Container(
                  height: 40,
                  width: 100,
                  color: _canApply == true ? Colors.blue[600] : Colors.grey[700],
                  child: _canApply ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                       if(_canApply) applySettings();
                      },
                        child: const Center(child: Text('Apply', style: TextStyle(color: Colors.white),))),
                  ) : const Center(child: Text('Apply', style: TextStyle(color: Colors.white),)),
                ),
              ),
              Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showOverlay = true;
                      });
                    },
                    child: const Text('Log Out', style: TextStyle(color: Colors.red),),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget overlayLogOutWidget() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
            border: Border.all(color: Colors.white),
          borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
        height: 200,
        width: 300,
        child: Stack(
          children: [
            Positioned(
                right: 10,
                child: closeButton(
                  callback: () {
                    setState(() {
                      _showOverlay = false;
                    });
                  },
                )
            ),
            Center(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white),),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            signOut();
                          });
                        },
                        child: const Text('Log Out', style: TextStyle(color: Colors.red),),
                    ),
                    SizedBox(height: 40,)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget blockedUsersWidget() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const UsersListScreen('blocked')
              ));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                      'Blocked Users',
                      style: TextStyle(color: Colors.white
                      )),
                  Icon(Icons.arrow_forward_ios_sharp, color: Colors.white,)
                ],
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: 0.5,
        )
      ],
    );
  }

  Widget textEditField(String tag) {

    Widget TextFieldWidget() {
      return IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    tag == 'displayName' ? 'Display Name'
                    : tag == 'bio' ? 'Bio'
                    : ''
                    ,
                  style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              const VerticalDivider(thickness: 0.5, width: 5, color: Colors.white,),
              const SizedBox(width: 5,),
              Expanded(
                child: TextField(
                  minLines: 1,
                  maxLines:
                      tag == 'displayName' ? 1
                      : tag == 'bio' ? 20
                      : null,
                  maxLength:
                      tag == 'displayName' ? 30
                      : tag == 'bio' ? 300
                      : null,
                  controller:
                      tag == 'displayName' ? _displayNameController
                      : tag == 'bio' ? _bioController
                      : null,
                  style: const TextStyle(color: Colors.white),
                  decoration:  InputDecoration(
                      hintText: tag == 'displayName' ? 'Enter a Display Name'
                          : tag == 'bio' ? 'Enter a Bio'
                          : null,
                      hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  onChanged: (val) {
                      setState(() {
                        _canApply = true;
                        if(tag == 'bio') _changeBio = true;
                        if(tag == 'displayName') _changeDisplayName = true;
                      });
                  },
                ),
              )
            ],
          ),
        );
    }

    Widget dividerWidget () {
      return const Divider(
        height: 0.5,
        color: Colors.white,
      );
    }

    return SizedBox(
      child: Column(
        children: [
          dividerWidget(),
          TextFieldWidget(),
          dividerWidget(),
        ],
      ),
    );
  }
}
