import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatelessWidget {

  final spinKit = const SpinKitDoubleBounce(
    color: Colors.white,
    size: 50,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: spinKit,
      ),
    );
  }


}