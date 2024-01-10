import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../../services/node_services/post_service.dart';

import '../../models/universal_widgets/close_button.dart';
import '../frame.dart';


class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({Key? key,}) : super(key: key);
  @override
  CameraCaptureScreenState createState() => CameraCaptureScreenState();
}

class CameraCaptureScreenState extends State<CameraCaptureScreen> with TickerProviderStateMixin {
  final awayCamera = cameras[0];
  final selfieCamera = cameras[1];
  bool camIsSelfie = true;
  bool ready = false, isRecording = false, isFlashOn = false, _visible = true, _overlayPress = true;
  double _scaleFactor = 1.0;
  double zoom = 1.0;
  Offset _focusOffset = const Offset(0, 0);
  File? file;
  late double scale;

  late CameraController _cameraController;
  late AnimationController _focusController;

  Future takePicture(CameraController cam) async {
    if(_visible && _overlayPress) {
      final XFile image = await cam.takePicture();
      if (camIsSelfie) {
        final Uint8List byteData = await image.readAsBytes();
        img.Image? originalImage = img.decodeImage(byteData);
        img.Image fixedImage = img.flipHorizontal(originalImage!);

        File file = File(image.path);

        await file.writeAsBytes(
          img.encodeJpg(fixedImage),
          flush: true,
        );
      }
      setState(() {
        file = File(image.path);
        _overlayPress = false;
        _visible = false;
      });
    }
  }

  uploadPost() {
    PostService.uploadGeoPost(imageFile: file!, type: 'image')
    .then((value) => Navigator.pop(context, [value]));
  }



  onScaleStartZoom() {
    if(_scaleFactor < 1) _scaleFactor = 1;
    zoom = _scaleFactor;
  }

  onScaleUpdateZoom(ScaleUpdateDetails details) {
    _scaleFactor = zoom * details.scale;
    if(_scaleFactor < 1) _scaleFactor = 1;
    _cameraController.setZoomLevel(_scaleFactor);
  }

  void onFocusTap(TapDownDetails details) {
    double fullHeight = MediaQuery
        .of(context)
        .size
        .height;
    double cameraWidth = fullHeight * _cameraController.value.aspectRatio;

    if (!camIsSelfie) {
      final offset = Offset(
        details.localPosition.dx / cameraWidth,
        details.localPosition.dy / fullHeight,
      );
      _cameraController.setExposurePoint(offset);
      _cameraController.setFocusPoint(offset);

      setState(() {
        _focusOffset = offset;
      });
      _focusController.forward();
    }
  }


  switchCamera() async {
    if(_visible && _overlayPress) {
      if (ready) {
        camIsSelfie = !camIsSelfie;
        _initCam();
      }
    }
  }

  Future _initCam() async {
    setState(() => ready = false);
    _cameraController = CameraController(camIsSelfie ? selfieCamera : awayCamera, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.yuv420,); /// Sets starting camera
    await _cameraController.initialize(); /// initializes camera controller
    await _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
    _cameraController.setFlashMode(FlashMode.off);
    setState(() => ready = true);
  }


  @override
  void initState() {
    super.initState();
    _initCam();
    _focusController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    _focusController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _cameraController.dispose(); /// disposes camera controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              if(file != null) {
                return SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.file(file!)
                      )
                  ),
                );
              }
              else if (ready) {
                // If the Future is complete, display the preview.
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                          child: CameraPreview(_cameraController)
                      )
                  ),
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          closeButton(
            icon: Icons.close,
            callback: file != null ?
            () => setState(() {file = null; _visible = true; _overlayPress = true;}) : null,
          ),
          AnimatedOpacity(
            // If the widget is visible, animate to 0.0 (invisible).
            // If the widget is hidden, animate to 1.0 (fully visible).
              onEnd: () => setState(() {_overlayPress = true;}),
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              // The green box must be a child of the AnimatedOpacity widget.
              child: captureOverlay()
          ),
          AnimatedOpacity(
              opacity: !_visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              // The green box must be a child of the AnimatedOpacity widget.
              child: uploadOverlay()
          )

        ],
      ),
    );
  }

Widget captureOverlay() {
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, right: 10),
            child: Align(
                alignment: Alignment.topRight,
                child: flashButton()
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(
                        width: 150,
                        height: 150,
                        child: GestureDetector(
                            onTap: () => takePicture(_cameraController),
                            child: captureWidgetPicture()
                        )
                    ),
                switchCameraButton()
                  ],
                )
            ),
          ),
        ),
      ],
    );
}

Widget uploadOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: _visible,
              child: GestureDetector(
                onTap: () => uploadPost(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                     Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40
                      ),
                    ),
                    SizedBox(width: 10,),
                    Icon(Icons.double_arrow_outlined, color: Colors.white, size: 50,)
                  ],
                ),
              ),
            )
        ),
      ),
    );
}

  Widget switchCameraButton() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Center(
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => switchCamera(),
          icon: const Icon(Icons.switch_camera_outlined, color: Colors.white, size: 40),
        ),
      ),
    );
  }

  Widget flashButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: GestureDetector(
        onTap: () {
          if(_visible && _overlayPress) {
            _cameraController.setFlashMode(!isFlashOn ? FlashMode.always : FlashMode.off);
            setState(() => isFlashOn = !isFlashOn);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isFlashOn ? Colors.white : null,
            shape: BoxShape.circle
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off_outlined,
              color: isFlashOn ? Colors.black : Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget captureWidgetPicture() {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        key: const ValueKey<int>(0),
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white,
                width: 5
            )
        ),
      ),
    );
  }
}
