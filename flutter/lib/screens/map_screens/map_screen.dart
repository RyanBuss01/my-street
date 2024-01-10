import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/classes/post.dart';
import '../../screens/upload_screens/camera_screen.dart';
import '../../models/classes/place.dart';
import '../../models/constants/tile_layer_options.dart';
import '../../models/custom_classes/overlay_class.dart';
import '../../services/internal_services/geo_locator_service.dart';
import '../../services/internal_services/map_service.dart';
import '../../services/internal_services/navigation_service.dart';
import '../../services/node_services/post_service.dart';
import '../frame.dart';
import '../profile_screens/profile_screen.dart';
import '../search_screens/search_screen.dart';
import 'overlay_screen.dart';



MapController mapController = MapController();

class MapScreen extends StatefulWidget {
  final Position? currentPosition; /// remove - replace with user.currentLocation
  final LatLng? newCords;
  final bool isLaunch;
  const MapScreen({Key? key, this.currentPosition, this.newCords, this.isLaunch = false}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng startPosition;
  late StreamSubscription<Position> positionStream;
  bool _showOverlay = false;
  late bool isMapCenter;
  late bool isWidgetBuilt = false;
  MapPosition? positionCamera;
  List<Marker> markers = [];
  Post? overlayPost;
  bool _isMeOverlay = false;
  Place? place;
  double zoom = 14;
  Timer? timer;

  late double latitudeOverlay;
  late double longitudeOverlay;

  // Future<Position?> getCurrentPosition() async => currentPosition = await GeoLocationService.getLocationPermission();

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  showOverlayCallback({bool value = false, post, double? latitude,  double? longitude}) {
    if(value == true) {
      latitudeOverlay = latitude!;
      longitudeOverlay = longitude!;
      setState(() {
        _isMeOverlay = false;
        overlayPost = post;
        _showOverlay = value;
      });
    }
    else {
      setState(() {
        _isMeOverlay = false;
        _showOverlay = value;
        overlayPost = post;
      });
    }
  }

  showUserOverlay({bool isMe = false, double? latitude, double? longitude}) {
    setState(() {
      latitudeOverlay = latitude ?? user.currentPosition.latitude;
      longitudeOverlay = longitude ?? user.currentPosition.longitude;
      _showOverlay = true;
      _isMeOverlay = isMe;
    });
  }

  showPlaceOverlayCallback(Place p) {
    setState(() {
      latitudeOverlay = p.lat;
      longitudeOverlay = p.long;
      _showOverlay = true;
      place = p;
    });
  }


  @override
  void initState() {
    if(widget.isLaunch) {
      user.postsFuture = PostService.getMyUserPosts();
    }
    if(widget.currentPosition != null) {
      user.currentPosition = widget.currentPosition!;
      mapController = MapController();
      isMapCenter = true;

      startPosition = widget.newCords ??
          LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude);

      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
            user.currentPosition = position ?? user.currentPosition;
          });

      if(widget.newCords != null) {
        LatLngBounds bounds = LatLngBounds.fromPoints([widget.newCords!]);
        // LatLngBounds bounds = LatLngBounds(LatLng(newCords!.latitude + 0.05, newCords!.longitude - 0.03), LatLng(newCords!.latitude - 0.05, newCords!.longitude + 0.03));
        mapMoveEventListener(
            MapPosition(
                center: widget.newCords,
                zoom: 12,
                bounds: bounds
            )
        );
      }
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => isWidgetBuilt = true);

   GeoLocationService.getLocationPermission(update: true);

    /// Repeating get position function
    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async => user.currentPosition = await GeoLocationService.getLocationPermission(update: true) ?? user.currentPosition);
  }

  Future<List<Marker>> mapMoveEventListener(MapPosition pos, {bool isStatic = false, LatLngBounds? bounds}) async {
        List<Marker> marks = [];
        var handlerResponse = await MapService.markerHandler(
            pos,
            zoom: pos.zoom ?? 14,
            bounds: bounds ?? pos.bounds,
            userOverlayCallback: showUserOverlay,
            geoPostOverlayCallback: showOverlayCallback,
          placeOverlayCallback: showPlaceOverlayCallback,
        );

        marks = handlerResponse ?? [];

        setState(() => markers = marks);

        return marks;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: OverlayClass(
        show: _showOverlay,
        backgroundTouchCallback: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (currentFocus.hasPrimaryFocus) {
            showOverlayCallback();
          }
          },
        overlay: _showOverlay ? OverlayScreen(post: overlayPost, callback: showOverlayCallback, isMe: _isMeOverlay, latitude: latitudeOverlay, longitude: longitudeOverlay, zoom: zoom, place: place)
        : const SizedBox(),
        child: Stack(
          children: [

            /// Flutter Map
            widget.currentPosition == null ? mapDeclinedWidget() : mapWidget(),

            /// Center Map button
            _showOverlay || widget.currentPosition == null
                ? const SizedBox()
                :  centerMapButton(),

            /// show top row buttons
            !_showOverlay || widget.currentPosition == null
                ? hudButtons()
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget hudButtons() {
    return SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, left: 15),
                child: Row(
                  children: [
                    mapButtonContainer(const Icon(Icons.person, size: 35, color: Colors.white), 'profile'),
                    mapButtonContainer(const Icon(Icons.search, size: 35, color: Colors.white), 'search', left: 15),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 30.0, right: 10),
                child: Row(
                  children: [
                    mapButtonContainer(const Icon(Icons.add, size: 35, color: Colors.white,), 'upload', right: 15),
                    mapButtonContainer(const Icon(Icons.message, size: 30, color: Colors.white,), 'message')

                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget centerMapButton() {
    return SafeArea(
      child: Center(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only( bottom: 30.0),
            child: AnimatedOpacity(
              opacity: !isMapCenter ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () {
                  mapController.move(LatLng(user.currentPosition.latitude, user.currentPosition.longitude), 14.0);
                  mapMoveEventListener(positionCamera!);
                  setState(() {
                    isMapCenter = true;
                  });
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle
                  ),
                  child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 35,
                    ),
                ),

              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mapWidget() {
    return FlutterMap(
      key: ValueKey(MediaQuery.of(context).orientation),
      mapController: mapController,
      options: MapOptions(

          slideOnBoundaries: true,
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          center: startPosition,
          zoom: 14.0,
          maxZoom: 18,
          minZoom: 4,
          swPanBoundary: LatLng(-80, -180), //Here is the issue
          nePanBoundary: LatLng(80, 180),
          onPositionChanged: (pos, bo) {
            positionCamera = pos;
            if( pos.center != startPosition) {
              setState(() {
                isMapCenter = false;
                zoom = pos.zoom!;
              });}
          },
          onMapReady: () {
            mapController.mapEventStream.listen((MapEvent mapEvent) async {
              if (mapEvent is MapEventMoveEnd) {
                await mapMoveEventListener(positionCamera!);
              }
            });

            final LatLngBounds startBounds = LatLngBounds(LatLng(widget.currentPosition!.latitude-0.05, widget.currentPosition!.longitude-0.03), LatLng(widget.currentPosition!.latitude+0.05, widget.currentPosition!.longitude+0.03));
            mapMoveEventListener(
              MapPosition(),
              isStatic: true,
              bounds: startBounds
            );
          },
      ),
      children: [
        tileLayerOptions,
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  mapDeclinedWidget() {
    return const Center(
      child: Text(
        'Turn on location services in settings to use map',
        style: TextStyle(color: Colors.white),
      ),
    );
  }


  Widget mapButtonContainer(Icon icon, String route, {double top = 0, double bottom = 0, double right = 0, double left = 0}) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom, right: right, left: left),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey[600]!.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: icon,
          onPressed: () {
            if(route == 'search') NavigationService.fadeUpRoute(context, const SearchScreen());
            if(route == 'upload') NavigationService.fadeUpRoute(context, const CameraCaptureScreen());
            // if(route == 'message') NavigationService.push(context, const SocialDashboard());
            if(route == 'profile') NavigationService.pushLeft(context, ProfilePage(userId: user.id, isLeading: false,));
          },
        ),
      ),
    );
  }

}




