import 'package:flutter/material.dart';

import '../../../../models/classes/user.dart';
import '../../../../services/internal_services/number_service.dart';
import '../../frame.dart';
import '../../profile_screens/profile_screen.dart';

class UserMarkerContainer extends StatefulWidget {
  final User userdata;
  final Function callback;
  const UserMarkerContainer({Key? key, required this.userdata, required this.callback}) : super(key: key);

  @override
  State<UserMarkerContainer> createState() => _UserMarkerContainerState();
}

class _UserMarkerContainerState extends State<UserMarkerContainer> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 450), vsync: this,);
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
      controller.forward();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: GestureDetector(
        onTap: () {
          if((widget.userdata.postCount != null && widget.userdata.postCount! > 0) || (widget.userdata.userCount != null && widget.userdata.userCount! > 1) ) {
            widget.callback(isMe: false, latitude: widget.userdata.latitude, longitude: widget.userdata.longitude);
          }
          else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage(userId: user.id,)));
        }
          },
        child: Stack(
          children: [
            avatarContainer(),
            widget.userdata.postCount != null && widget.userdata.postCount! > 0
                ? geoPostStackNumberWidget()
                : const SizedBox(),
            widget.userdata.userCount != null && widget.userdata.userCount! > 1
                ? userStackNumberWidget()
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget avatarContainer() {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(widget.userdata.avatar),
              fit: BoxFit.cover
          ),
          border: Border.all(color: Colors.blueAccent, width: 2)
      ),
    );
  }

  plusWidget() {
    return Transform.translate(
        offset: const Offset(62, 76),
      child: Container(
        height: 30,
        width: 30,
      decoration: BoxDecoration(
    color: Colors.blue[800],
      shape: BoxShape.circle
    ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget geoPostStackNumberWidget() {
    String stackLength = NumberService.scaleNumberString(widget.userdata.postCount!);
    return Transform.translate(
      offset: const Offset(34, -40),
      child: Align(
        child: Container(
          height: 35,
          width: 35,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape:BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stackLength,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: stackLength.length == 1 ? 25 : stackLength.length == 2 ? 20 : stackLength.length == 3 ? 15 : 13
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget userStackNumberWidget() {
    String stackLength = NumberService.scaleNumberString(widget.userdata.userCount!);
    return Transform.translate(
      offset: const Offset(-34, -40),
      child: Align(
        child: Container(
          height: 35,
          width: 35,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape:BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stackLength,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: stackLength.length == 1 ? 25 : stackLength.length == 2 ? 20 : stackLength.length == 3 ? 15 : 13
              ),
            ),
          ),
        ),
      ),
    );
  }
}
