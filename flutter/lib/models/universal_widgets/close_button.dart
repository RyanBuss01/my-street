import 'package:flutter/material.dart';

class closeButton extends StatelessWidget {
  final IconData icon;
  final Function? callback;
  const closeButton({Key? key, this.icon = Icons.close,  this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 15),
          child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {callback != null ? callback!() : Navigator.pop(context);},
                icon: Icon(icon, color: Colors.white, size: 40),
              )
          ),
        )
    );
  }
}



