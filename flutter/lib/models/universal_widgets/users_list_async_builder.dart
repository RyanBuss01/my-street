import 'package:flutter/material.dart';
import '../../services/node_services/user_service.dart';

import '../../services/node_services/friend_service.dart';
import '../classes/user.dart';
import '../../services/internal_services/navigation_service.dart';
import '../../screens/profile_screens/profile_screen.dart';
import '../../screens/profile_screens/users_list_screen.dart';
import '../../screens/frame.dart';

AsyncWidgetBuilder usersListAsyncBuilder(String widgetKey, {required ScrollController controller, required bool isLimitReached, required bool isQuerying, required List<User> users}) {
  return (context, snap) {
    if(snap.connectionState == ConnectionState.done) {
      return UsersListViewBuilderWidget(
          widgetKey,
          controller: controller,
          isLimitReached: isLimitReached,
          isQuerying: isQuerying,
          users: users
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  };
}

class UsersListViewBuilderWidget extends StatefulWidget {
  final ScrollController controller;
  final bool isLimitReached;
  final bool isQuerying;
  final List<User> users;
  final String widgetKey;
  const UsersListViewBuilderWidget(this.widgetKey, {Key? key, required this.controller, required this.isLimitReached, required this.isQuerying, required this.users}) : super(key: key);

  @override
  State<UsersListViewBuilderWidget> createState() => _UsersListViewBuilderWidgetState();
}

class _UsersListViewBuilderWidgetState extends State<UsersListViewBuilderWidget> {
  late List<User> users = widget.users;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: (user.hasRequest && widget.widgetKey == 'friends') ? users.length + 1 : users.length,
        itemBuilder: (context, index) {
          if(user.hasRequest && widget.widgetKey == 'friends' && index == 0) {
            return friendRequestWidget();
          }
          else if (user.hasRequest && widget.widgetKey == 'friends') { return userCard(users[index - 1]);}
          else {return userCard(users[index]);}
        }
    );
  }

  Widget friendRequestWidget() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UsersListScreen('request')))
              .then((value) => setState(() {}));
        },
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Friend Requests',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white,)
                  ],
                ),
              ),
              const Divider(color: Colors.grey, thickness: 1,)
            ],
          ),
        ),
      ),
    );
  }

  Widget userCard(User userdata) {
    if(widget.widgetKey == 'friend') {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            NavigationService.push(
                context, ProfilePage(userId: userdata.id, isLeading: true));
          },
          child: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: ClipOval(
                              child: Image.network(
                                userdata.avatar, fit: BoxFit.cover,)
                          ),
                        ),
                      ),
                      Text(
                        userdata.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white,)
              ],
            ),
          ),
        ),
      );
    }

if(widget.widgetKey == 'request') {
  SizedBox(
    height: 100,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userdata.displayName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        FriendsService().addFriend(
                            userdata, forcedStatus: 'receiver')
                            .then((value) {
                          users.remove(userdata);
                          setState(() {});
                        });
                      },
                      icon: const Icon(
                        Icons.check, color: Colors.greenAccent, size: 35,)
                  ),
                  const SizedBox(width: 10,),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.close, color: Colors.red, size: 35)
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(
          color: Colors.white,
        )
      ],
    ),
  );
}

    if(widget.widgetKey == 'blocked') {
      return SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: GestureDetector(
                            onTap: () {
                              // NavigationService.push(context, ProfilePage(userdata: userdata, isLeading: true));
                            },
                            child: ClipOval(
                                child: Image.network(
                                  userdata.avatar, fit: BoxFit.cover,)
                            ),
                          ),
                        ),
                      ),
                      Text(
                        userdata.displayName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: IconButton(
                        onPressed: () {
                          UserService().unBlockUser(userdata.id)
                              .then((value) {
                                if(value == 200) {
                                  users.remove(userdata);
                                  setState(() {});
                                }
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.white, size: 30,)
                    ),
                  )
                ],
              ),
            ),
            const Divider(color: Colors.white,)
          ],
        ),
      );
    }

return const SizedBox();

  }

}
