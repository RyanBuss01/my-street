import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/universal_widgets/close_button.dart';

import '../../screens/frame.dart';
import '../custom_classes/custom_paint_live_reply_image.dart';
import 'package:image/image.dart' as img;

class LiveReplyWidget extends StatefulWidget {
  bool liveVisible;
  final Function onUpload;
  final Function onClose;
  LiveReplyWidget(
      {Key? key,
      required this.liveVisible,
      required this.onUpload,
      required this.onClose})
      : super(key: key);

  @override
  State<LiveReplyWidget> createState() => _LiveReplyWidgetState();
}

class _LiveReplyWidgetState extends State<LiveReplyWidget> {
  File? file;
  late CameraController _cameraController;
  final selfieCamera = cameras[1];

  bool ready = false, liveVisible = false;

  Future takePicture(CameraController cam) async {
    if (file == null) {
      final XFile image = await cam.takePicture();
      final Uint8List byteData = await image.readAsBytes();
      img.Image? originalImage = img.decodeImage(byteData);
      img.Image fixedImage = img.flipHorizontal(originalImage!);

      File imgFile = File(image.path);

      await imgFile.writeAsBytes(
        img.encodeJpg(fixedImage),
        flush: true,
      );
      setState(() {
        file = File(image.path);
      });
    }
  }

  _initCam() async {
    _cameraController = CameraController(
      selfieCamera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    /// Sets starting camera
    await _cameraController.initialize();

    /// initializes camera controller
    await _cameraController
        .lockCaptureOrientation(DeviceOrientation.portraitUp);
    setState(() => ready = true);
  }

  @override
  void initState() {
    _initCam();
    super.initState();
  }

  @override
  didUpdateWidget(LiveReplyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (liveVisible != widget.liveVisible) {
      setState(() => liveVisible = widget.liveVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        liveReplyScreen(),
        file != null ? replyScreen() : const SizedBox(),
        liveVisible
            ? closeButton(
                callback: () => setState(() {
                      if (file != null) {
                        file = null;
                      } else {
                        widget.onClose();
                      }
                    }))
            : const SizedBox()
      ],
    );
  }

  Widget liveReplyScreen() {
    return AnimatedOpacity(
      opacity: liveVisible && file == null ? 1 : 0,
      duration: const Duration(milliseconds: 100),
      child: IgnorePointer(
        ignoring: !liveVisible,
        child: Stack(
          children: [
            SizedBox.expand(
                child: GestureDetector(
                    onTap: () => setState(() {
                          widget.onClose();
                        }),
                    child: Container(
                        color: Colors.black54,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 350,
                                child: Builder(builder: (context) {
                                  if (ready) {
                                    return ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(40.0),
                                        child:
                                            CameraPreview(_cameraController));
                                  }
                                  return const CircularProgressIndicator();
                                }),
                              ),
                            ),
                            Builder(builder: (context) {
                              if (ready) {
                                return Center(
                                    child: SizedBox(
                                        width: 350,
                                        height: 350 *
                                            _cameraController.value.aspectRatio,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                            child:
                                                const OverlayWithRectangleClipping())));
                              }
                              return const SizedBox();
                            })
                          ],
                        )))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 5)),
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: ClipOval(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => takePicture(_cameraController),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget replyScreen() {
    return SizedBox.expand(
      child: Container(
        color: Colors.black54,
        child: Stack(
          children: [
            Center(
              child: CircleAvatar(
                radius: 175,
                backgroundImage: FileImage(file!),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      ignoring: file == null,
                      child: GestureDetector(
                        onTap: () {
                          widget.onUpload(file!);
                          file = null;
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Upload',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.double_arrow_outlined,
                              color: Colors.white,
                              size: 50,
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
