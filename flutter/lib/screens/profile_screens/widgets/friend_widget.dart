import 'package:flutter/material.dart';
import '../../../screens/frame.dart';

import '../../../services/internal_services/navigation_service.dart';
import '../../../services/node_services/friend_service.dart';
import '../../../models/classes/user.dart';
import '../users_list_screen.dart';

class FriendWidget extends StatefulWidget {
  final User userdata;
  final Function callback;
  final String? status;
  const FriendWidget({Key? key,  required this.userdata, required this.callback, this.status}) : super(key: key);

  @override
  _FriendWidgetState createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  late String status;

  @override
  void initState() {
    status = widget.status ?? widget.userdata.friendStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (status == 'isMe') { NavigationService.push(context, const UsersListScreen('friend')); }
              else if(status == 'friend') { widget.callback();}
              else {
                FriendsService().addFriend(widget.userdata)
                  .then((value) {setState(() {
                   if(status == 'none') { status = 'sender'; }
                   else if(status == 'sender') { status = 'none'; }
                   else if(status == 'receiver') { status = 'friend'; }
                  });});
            }},
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  if (status == 'isMe') const Icon(Icons.person, color: Colors.white, size: 50,)
                  else if(status == 'sender') const Icon(Icons.person, color: Colors.white, size: 50,)
                  else if(status == 'friend') const Icon(Icons.person, color: Colors.blue, size: 50,)
                    else const Icon(Icons.person_outline, color: Colors.white, size: 50,),

                  if(status == 'isMe') Row(
                    children:  [
                       const Text('Friends', style: TextStyle(color: Colors.white),),
                      (status == 'isMe' && user.hasRequest)
                          ? Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration:  BoxDecoration(
                                  color: Colors.red[600],
                                  shape: BoxShape.circle
                              ),
                            ),
                          )
                          : const SizedBox()
                    ],
                  )
                  else if(status == 'sender') const Text('Request Sent', style: TextStyle(color: Colors.white),)
                  else if(status == 'friend') const Text('Friend', style: TextStyle(color: Colors.white),)
                    else const Text('Add Friend', style: TextStyle(color: Colors.white),)

                ],
              ),
            )
        ),
      );
    }
  }
