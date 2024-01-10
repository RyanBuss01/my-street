import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../screens/profile_screens/profile_post_screen.dart';
import '../../screens/upload_screens/camera_screen.dart';
import '../../services/internal_services/fade_transition.dart';
import '../../services/node_services/post_service.dart';
import '../../models/classes/post.dart';
import '../../screens/map_screens/map_screen.dart';
import '../../screens/profile_screens/widgets/upload_status_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../models/constants/tile_layer_options.dart';
import '../../models/universal_widgets/close_button.dart';
import '../../screens/profile_screens/settings_screen.dart';
import '../../screens/profile_screens/widgets/confirmation_widget.dart';

import '../../models/classes/user.dart';
import '../../models/custom_classes/overlay_class.dart';
import '../../services/internal_services/number_service.dart';
import '../map_screens/markers/user_marker.dart';
import 'widgets/friend_widget.dart';
import '../../services/node_services/user_service.dart';
import '../frame.dart';


class ProfilePage extends StatefulWidget {
  final int? userId;
  final bool isLeading;
  final String? username;

  const ProfilePage({Key? key,  this.userId, this.isLeading = true, this.username}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _isMe;
  late User userdata;
  late Future _userFuture;
  late LatLng startPosition;
  bool _showOverlay = false, isMuted = true;
  String? status;
  Future? _storyFuture, _postsFuture;
  User? selectedUser;
  int pageIndex = 0;

  List<Post> posts = [];
  List<int> visiblePosts = [];

  final PanelController _panelController = PanelController();


  Future<User> getUserData() async {
    userdata =  await UserService().getUserdata(widget.userId, isProfilePage: true, username: widget.username);
      _postsFuture = getUserPosts();
    // _storyFuture = getUserStories(userdata.id);
    return userdata;
  }

  Future getUserPosts() async {
    posts = await PostService.getUserPosts(userdata.id);
    return posts;
  }



  @override
  void initState() {
    _isMe = widget.userId == user.id || widget.username == user.username;
    if(_isMe) {
      userdata = User.fromMyUser(user, latitude: user.currentPosition.latitude, longitude: user.currentPosition.longitude);
      posts = user.posts;
    }
    else {
      _userFuture = getUserData();
    }

    super.initState();
  }

  toggleOverlay() {
     setState(() {
       _showOverlay = !_showOverlay;
     });
  }

  toggleStatus() {
    setState(() {
      status = 'none';
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder(
            future: _isMe ? null : _userFuture,
            builder: (context, snap) {
              if(_isMe) {
                return scrollViewWidget();
              }
              else if(snap.connectionState == ConnectionState.done) {
                if(snap.data == null) {
                  return const Center(
                      child: Text('No user found', style: TextStyle(color: Colors.white, fontSize: 25),)
                  );
                }
                return scrollViewWidget();
              }
              else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.grey,),
                );
              }
            }
          ),
          returnButton(),
        ],
      ),
    );
  }

  Widget scrollViewWidget() {
    return OverlayClass(
      show: _showOverlay,
      overlay: ConfirmationOverlayWidget(
        text: 'Are you sure you want to remove this User as a friend',
        confirmationText: 'Remove Friend',
        confirmationButton: () => UserService().removeFriend(userdata).then((value) => toggleStatus()),
        callback: toggleOverlay,
      ),
      backgroundTouchCallback: toggleOverlay,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx < -20) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                avatarImageWidget(),
                profileInfoWidget(),
                // storiesWidget()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget storiesWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _isMe ? SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const EditStoriesScreen()));
                  },
                  child: Row(
                    children: const [
                       Text(
                        'View stories',
                        style: TextStyle(color: Colors.blue),
                      ),
                      Icon(Icons.arrow_forward, color: Colors.blue,)
                    ],
                  ),
                )
              ],
            ),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  Widget avatarImageWidget() {
    return SliverAppBar(
      backgroundColor: Colors.grey[900],
      stretch: true,
      expandedHeight: 400,
      flexibleSpace: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if((posts.isEmpty && !_isMe) || (_isMe && user.posts.isEmpty)) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CameraCaptureScreen()));
              }
            },
            child: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.blurBackground
                    ],
                    background: FutureBuilder(
                      future: _isMe ? user.postsFuture :  _postsFuture,
                      builder: (context, snap) {
                        if (posts.isNotEmpty) {
                          return PageView.builder(
                            onPageChanged: (i) {
                              setState(() {
                                pageIndex = i;
                              });
                            },
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                return  GestureDetector(
                                  onTap: () {
                                      Navigator.of(context).push(FadeRoute(ProfilePostScreen(posts: posts, initialIndex: index,)));
                                  },
                                  child: Image(
                                      image: NetworkImage(
                                        posts[index].media,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                );
                              });
                        } else if (snap.connectionState == ConnectionState.done && posts.isEmpty) {
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Image(
                              image: NetworkImage(
                                userdata.avatar,
                              ),
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return const Center(
                            child: CircularProgressIndicator(color: Colors.white,)
                        );
                      }
                    ),
                  )
          ),
           Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CameraCaptureScreen()));
                },
                  child: const Icon(Icons.add_circle, color: Colors.lightBlueAccent, size: 40,)),
            )
          ),
          FutureBuilder(
            future: _isMe ? user.postsFuture :  _postsFuture,
            builder: (context, snap) {
              if(posts.length > 1) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 30,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: posts.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 10),
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                  color: index == pageIndex
                                      ? Colors.white
                                      : Colors.grey,
                                  shape: BoxShape.circle
                              ),
                            ),
                          );
                        }),
                  ),
                );
              }
              return const SizedBox();
            }
          )
        ],
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget profileInfoWidget() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            color: Colors.black,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Text(
                              userdata.displayName,
                              maxLines: 3,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 25
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            '@${userdata.username}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            userdata.bio ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _isMe ? [
                        // FriendIcon(user: widget.user, isMe: _isMe,),
                         FriendWidget(userdata: userdata, callback: toggleOverlay),

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.push(context, (MaterialPageRoute(builder: (context) =>  const SettingsPage())))
                                  .then((value) => setState(() {
                                    if(_isMe) { userdata = User.fromMyUser(user, latitude: user.currentPosition.latitude, longitude: user.currentPosition.longitude);}
                              }));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: const [
                                  Icon(Icons.settings, color: Colors.white, size: 50,),

                                  Text('Settings', style: TextStyle(color: Colors.white),)
                                ],
                              ),
                            ),
                          ),
                        )
                      ]
                      : [
                        userdata.friendStatus == 'sent' ? FriendWidget(userdata: userdata, callback: toggleOverlay)
                        : userdata.isFriend ? FriendWidget(userdata: userdata, callback: toggleOverlay, status: status,)
                        : FriendWidget(userdata: userdata, callback: toggleOverlay),

                        Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => DirectChatRoomScreen(user: userdata, chatRoom: null,)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: const [
                              Icon(Icons.message, color: Colors.white, size: 50,),

                              Text('message', style: TextStyle(color: Colors.white),)
                            ],
                          ),
                        ),
                      ),
                    ),


                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                        setState(() {
                          selectedUser = userdata;
                          // _showPanel = true;
                        });
                        _panelController.open();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: const [
                              Icon(Icons.more_horiz, color: Colors.white, size: 50,),

                              Text('more', style: TextStyle(color: Colors.white),)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                    ),
                    _isMe && user.uploads.isNotEmpty ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: user.uploads.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return UploadStatusWidget(
                              upload: user.uploads[index],
                              index: index
                          );
                        }
                    )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          mapWidget(),
          const SizedBox(height: 5,),
          _isMe ? const SizedBox() : Text(NumberService.timeAgoHandler(userdata.timestamp!), style: const TextStyle(color: Colors.grey),),
          const SizedBox(height: 10,),
          const Divider(
            height: 2,
            color: Colors.white,
          )
        ],
      ),
    );
  }

  Widget returnButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Align(
          alignment: widget.isLeading ? Alignment.topLeft : Alignment.topRight,
          child: IconButton(
            icon: Icon(
              widget.isLeading ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
              color: Colors.white, size: 30,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }


  Widget blockUserWidget() {
    return Center(
      child: Container(
          height: 500,
          width: 400,
          color: Colors.black,
          child: Column(
            children: [
              closeButton(callback: () {
                toggleOverlay();
              }),
              TextButton(
                  onPressed: () {
                    // UserService().blockUser();
                  },
                  child: const Text(
                    'Block User',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          )
      ),
    );
  }

  Widget mapWidget() {
    if(!userdata.isFriend && !_isMe) {
      return const SizedBox();
    }
    else if(_isMe) {
      startPosition = LatLng(userdata.latitude!, userdata.longitude!);
      Marker marker = Marker(
          width: 100,
          height: 100,
          point: LatLng(userdata.latitude!, userdata.longitude!),
          builder: (ctx) {
            return UserMarkerContainer(userdata: userdata, callback: () {},);
          }
      );
      return GestureDetector(
        child: Container(
            height: 200,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20))
            ),
            width: (MediaQuery.of(context).size.width * 0.9),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: IgnorePointer(
                  ignoring: true,
                  child: FlutterMap(
                    key: ValueKey(MediaQuery.of(context).orientation),
                    options: MapOptions(
                      slideOnBoundaries: false,
                      interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      center: startPosition,
                      zoom: 14.0,
                      maxZoom: 10,
                      minZoom: 10,
                      swPanBoundary: LatLng(-80, -180),
                      nePanBoundary: LatLng(80, 180),
                    ),
                    children: [
                      tileLayerOptions,
                      MarkerLayer(
                        markers: [marker],
                      ),
                    ],
                  ),
                )
            )
        ),
      );
    }
    else if(userdata.isFriend) {
      startPosition = LatLng(userdata.latitude!, userdata.longitude!);
      Marker marker = Marker(
          width: 100,
          height: 100,
          point: LatLng(userdata.latitude!, userdata.longitude!),
          builder: (ctx) {
            return UserMarkerContainer(userdata: userdata, callback: () {},);
          }
      );
    return GestureDetector(
      onTap: () {
        LatLng newCords = LatLng(userdata.latitude!, userdata.longitude!);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MapScreen(currentPosition: user.currentPosition, newCords: newCords)), (route) => false);
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(20))
        ),
        width: (MediaQuery.of(context).size.width * 0.9),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IgnorePointer(
            ignoring: true,
            child: FlutterMap(
              key: ValueKey(MediaQuery.of(context).orientation),
              options: MapOptions(
                slideOnBoundaries: false,
                interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                center: startPosition,
                zoom: 14.0,
                maxZoom: 10,
                minZoom: 10,
                swPanBoundary: LatLng(-80, -180),
                nePanBoundary: LatLng(80, 180),
              ),
              children: [
                tileLayerOptions,
                MarkerLayer(
                  markers: [marker],
                ),
              ],
            ),
          )
        )
      ),
    );
  }
    else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(20))
        ),
        child: SizedBox.expand(
          child: Container(
            color: Colors.grey,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
  }

}
