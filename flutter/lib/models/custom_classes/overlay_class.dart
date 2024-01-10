import 'package:flutter/material.dart';

import '../universal_widgets/close_button.dart';

class OverlayClass extends StatefulWidget {
  const OverlayClass({
    super.key,
    this.hasBackground = true,
    required this.show,
    required this.child,
    required this.overlay,
    this.closeButtonCallback,
    this.backgroundTouchCallback,
  });

  final bool show;
  final bool hasBackground;
  final Widget child;
  final Widget overlay;
  final Function? closeButtonCallback;
  final Function? backgroundTouchCallback;

  @override
  State<OverlayClass> createState() => _OverlayClassState();
}

class _OverlayClassState extends State<OverlayClass> {




  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        widget.child,
            Stack(
              children: [
                blackOverlay(),
                widget.show == true
                    ? widget.overlay
                : SizedBox(),
                // wid()
              ],
            )
      ],
    );
  }

  Widget blackOverlay() {
    return IgnorePointer(
      ignoring: !widget.show,
      child: GestureDetector(
        onTap: () {
          print('run');
          widget.backgroundTouchCallback != null ? widget.backgroundTouchCallback!() : () {};
        },
        child: AnimatedOpacity(
          opacity: widget.show ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            color: Colors.black54,
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
          ),
        ),
      ),
    );
  }

  Widget wid () {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: widget.show ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Container(
            height: 200,
            width: 200,
            color: Colors.black,
            child: Stack(
              children: [
                 const Positioned(
                  top: 10,
                  right: 10,
                  child: closeButton(),
                ),
                widget.child
              ],
            )
        ),
      ),
    );
  }
}



