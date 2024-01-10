import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../services/internal_services/number_service.dart';
import '../../../models/classes/post.dart';
import '../map_screen.dart';



class AnimatedGeoPostContainer extends StatefulWidget {
  final Post post;
  final double zoom;
  final Function callback;
  const AnimatedGeoPostContainer({Key? key, required this.post, required this.zoom, required this.callback}) : super(key: key);

  @override
  _AnimatedGeoPostContainerState createState() => _AnimatedGeoPostContainerState();
}

class _AnimatedGeoPostContainerState extends State<AnimatedGeoPostContainer> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 450), vsync: this,);
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () {
          mapController.move(LatLng(widget.post.latitude, widget.post.longitude), widget.zoom);
          widget.callback(value: true, post: widget.post, latitude: widget.post.latitude, longitude: widget.post.longitude);
        },
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Stack(
            children: [
             imageMarkerWidget(),

              widget.post.stackCount != null && widget.post.stackCount! > 1
                  ? geoPostStackNumberWidget()
                  : const SizedBox()
            ],
          ),
        ),
      );
  }

  Widget textMarkerWidget() {
    return Container(
      height: 90.0,
      width: 160,
      decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          border: Border.all(color: Colors.white, width: 2,),
          borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.post.user!.avatar)
                      )
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    widget.post.user!.displayName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),),
                ],
              ),
              const SizedBox(height: 10,),
              Text(
                widget.post.caption!,
                style: const TextStyle(
                    color: Colors.white
                ),),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageMarkerWidget() {
    return Container(
      width: 84.0,
      height: 190.0,
      decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          border: Border.all(color: Colors.white, width: 2,),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(widget.post.media,)
          )
      ),
    );
  }

  Widget imageWithTextMarkerWidget() {
    return Container(
      width: 200,
      height: 190.0,
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        border: Border.all(color: Colors.white, width: 2,),
        borderRadius: const BorderRadius.all(Radius.circular(20)),

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 84,
            height: 190.0,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.white, width: 2,),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.post.media,)
                )
            ),
          ),

          SizedBox(
            width: 110,
            child:  Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Center(
                child: Text(
                  widget.post.caption!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 6,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget geoPostStackNumberWidget() {
    String stackLength = NumberService.scaleNumberString(widget.post.stackCount!);
    return Transform.translate(
      offset: const Offset(38, -90),
      child: Align(
        child: Container(
          height: 40,
          width: 40,
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

}


