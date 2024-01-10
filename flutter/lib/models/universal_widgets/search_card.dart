import 'package:flutter/material.dart';

import '../../screens/profile_screens/profile_screen.dart';
import '../classes/user.dart';

Material searchCard(BuildContext context, {User? userInfo, Function? callBack, String type = 'user', bool showNavigateIcon = true}) {
  return Material(
    borderRadius: BorderRadius.circular(20),
    color: Colors.blueGrey[700],
    child: InkWell(
      onTap: () {
        if(callBack == null) {
          if(type == 'user') {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                Material(
                  type: MaterialType.transparency,
                  child: Container(
                      color: Colors.black,
                      child: ProfilePage(userId: userInfo?.id, isLeading: true)
                  ),
                )));
          }
      }
        else {
          callBack(userdata : userInfo);
        }
        },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  type == 'user'?
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ClipOval(
                      child: Image(
                        image: NetworkImage(userInfo!.avatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : type == 'hashTag' ?
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black
                    ),
                    child: const Icon(Icons.tag, color: Colors.white,),
                  )
                      : const SizedBox(),
                  const SizedBox(width: 20,),
                  Text(
                    type == 'user' ? userInfo!.displayName
                        : '',
                    style: const TextStyle(color: Colors.white),)
                ],
              ),
              Row(
                children: [
                  type == 'user' && userInfo!.isFriend ?
                   const Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 5.0),
                    child:  Icon(Icons.people, color: Colors.blue, size: 35,),
                  )
                  : const SizedBox(),
                  showNavigateIcon ?
                  const Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 10.0),
                    child:  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25,),
                  )
                      : const SizedBox(),
                ],
              )
            ],
          ),
        ),
      ),
    ),
  );
}