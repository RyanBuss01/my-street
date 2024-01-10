import 'package:flutter/material.dart';

import '../../../models/classes/place.dart';
import '../../../services/internal_services/number_service.dart';

class PlaceMarkerContainer extends StatefulWidget {
  final Place place;
  final Function callback;
  const PlaceMarkerContainer({Key? key, required this.place, required this.callback}) : super(key: key);

  @override
  State<PlaceMarkerContainer> createState() => _PlaceMarkerContainerState();
}

class _PlaceMarkerContainerState extends State<PlaceMarkerContainer> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Place place = widget.place;

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
            widget.callback(place);
        },
        child: Stack(
          children: [
            avatarContainer(),
            (place.postCount != null && place.postCount! > 0)
                ? geoPostStackNumberWidget()
                : const SizedBox(),
            (place.userCount != null && place.userCount! > 0)
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
          image: place.media != null ? DecorationImage(
              image: NetworkImage(place.media!),
              fit: BoxFit.cover
          ) : null,
          color: Colors.grey[700],
          border: Border.all(color: Colors.greenAccent, width: 2)
      ),
      child: place.media != null ? null : const Icon(Icons.place, color: Colors.white, size: 50,)
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
    String stackLength = NumberService.scaleNumberString(place.postCount!);
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
    String stackLength = NumberService.scaleNumberString(place.userCount!);
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
