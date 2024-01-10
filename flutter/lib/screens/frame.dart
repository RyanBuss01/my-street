import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geolocator/geolocator.dart';

import '../models/classes/myUser.dart';
import '../services/internal_services/camera_service.dart';
import '../services/internal_services/geo_locator_service.dart';
import '../services/node_services/user_service.dart';
import 'authenticate/widgets/logo_loading_widget.dart';
import 'map_screens/map_screen.dart';


late MyUser user;
late IO.Socket socket;

late Future uploadStoriesFuture;

// Obtain a list of the available cameras on the device.
late List<CameraDescription> cameras;

class Frame extends StatefulWidget {
  final int id;
  const Frame({Key? key, required this.id}) : super(key: key);

  @override
  _FrameState createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  var futures;
  MyUser? userdata;
  Position? _currentPosition;

  Future<Position?> getCurrentPosition() async => _currentPosition = await GeoLocationService.getLocationPermission();
  Future<MyUser> getUser() async => userdata = await UserService().getMyUserdata(widget.id, isMe: true, pos: _currentPosition!);
  Future<List<CameraDescription>> getCameras() async => cameras = await CameraService.getCameraDescriptions();


  Future getData() async {
    await getCurrentPosition();
    await getUser();
    await getCameras();
    return [userdata, _currentPosition, cameras];
  }

  @override
  void initState() {
    super.initState();
    futures = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futures,
        builder: (context, snap) {
          if(snap.connectionState == ConnectionState.done )
          {

            if(userdata != null) {
              user = userdata!;
              return MapScreen(currentPosition: _currentPosition, isLaunch: true,);
            }
            else {
              return frameErrorScreen();
            }
          }
          else { return logoLoadingWidget(); }
      }
    );
  }

  Widget frameErrorScreen({String errorText = 'error connecting to server'}) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
           Center(
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(
                  onPressed: () {
                    getData().then((value) => setState(() {}));
                  },
                  icon: const Icon(Icons.refresh, size: 40, color: Colors.white,),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
