import 'package:flutter/material.dart';
import '../../models/classes/chunkLoaderListView.dart';
import '../../screens/profile_screens/profile_screen.dart';

import '../../models/classes/user.dart';
import '../../services/internal_services/navigation_service.dart';
import '../../services/node_services/friend_service.dart';
import '../../services/node_services/user_service.dart';
import '../frame.dart';


class UsersListScreen extends StatefulWidget {
  final String tag;
  const UsersListScreen(this.tag, {Key? key}) : super(key: key);

  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late String tag = widget.tag;
  List<User> users = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title:  Text(
            tag == 'friend' ? 'Friends'
            : tag == 'requests' ? 'Friend Requests'
            : tag == 'blocked' ? 'Blocked Users'
            : '',
            style: const TextStyle(
                color: Colors.white
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.5),
            child: Container(
              color: Colors.grey,
              height: 1,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: ChunkLoader(
          futureKey: tag,
          builder: ((context, snap, loader) {
            if(snap.connectionState == ConnectionState.done) {
              users = loader.users;
              return  ListView.builder(
                  controller: loader.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: (user.hasRequest && loader.futureKey == 'friends') ? users.length + 1 : users.length,
                  itemBuilder: (context, index) {
                    if(user.hasRequest && loader.futureKey == 'friends' && index == 0) {
                      return friendRequestWidget();
                    }
                    else if (user.hasRequest && loader.futureKey == 'friends') { return userCard(users[index - 1], loader.futureKey!);}
                    else {return userCard(users[index], loader.futureKey);}
                  }
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        )
    );
  }

  // Material userCard(User userdata) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: () {
  //         NavigationService.push(context, ProfilePage(userdata: userdata, isLeading: true));
  //       },
  //       child: SizedBox(
  //         height: 100,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(top: 20.0, left: 10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Padding(
  //                     padding:  EdgeInsets.only(right: 20.0),
  //                     child: SizedBox(
  //                       height: 50,
  //                       width: 50,
  //                       child: ClipOval(
  //                           child: Image.network( userdata.avatar, fit: BoxFit.cover,)
  //                       ),
  //                     ),
  //                   ),
  //                   Text(
  //                     userdata.displayName,
  //                     style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 25
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             const Divider(color: Colors.white,)
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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

  Widget userCard(User userdata, String futureKey) {
    if(futureKey == 'friend') {
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

    if(futureKey == 'request') {
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

    if(futureKey == 'blocked') {
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
