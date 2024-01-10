import 'package:flutter/material.dart';

import '../../../../models/classes/user.dart';
import '../../../../services/internal_services/number_service.dart';
import '../../../models/classes/myUser.dart';
import '../../frame.dart';
import '../../profile_screens/profile_screen.dart';

class MyUserMarkerContainer extends StatefulWidget {
  final MyUser userdata;
  final Function callback;
  final int? stackCount;
  final int? userStackCount;
  final bool isMe;
  const MyUserMarkerContainer({Key? key, required this.userdata, required this.callback, this.stackCount, this.userStackCount, this.isMe = false}) : super(key: key);

  @override
  State<MyUserMarkerContainer> createState() => _MyUserMarkerContainerState();
}

class _MyUserMarkerContainerState extends State<MyUserMarkerContainer> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late bool isMe = widget.isMe;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: isMe ? 0 : 450), vsync: this,);
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
          if(user.id == widget.userdata.id) {
            widget.callback(isMe: isMe);
          }
          else {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfilePage(userId: user.id,)));
          }
        },
        child: Stack(
          children: [
            avatarContainer(),
            isMe ? plusWidget()
                : const SizedBox(),
            widget.stackCount != null
                ? geoPostStackNumberWidget()
                : const SizedBox(),
            widget.userStackCount != null
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
    String stackLength = NumberService.scaleNumberString(widget.stackCount!);
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
    String stackLength = NumberService.scaleNumberString(widget.userStackCount!);
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