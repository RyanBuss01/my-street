import 'dart:async';

import 'package:flutter/material.dart';
import '../../../services/internal_services/upload_service.dart';

import '../../../models/classes/upload.dart';
import '../../frame.dart';

class UploadStatusWidget extends StatefulWidget {
  final Upload upload;
  final int index;
  const UploadStatusWidget({required this.upload, required this.index, Key? key}) : super(key: key);

  @override
  State<UploadStatusWidget> createState() => _UploadStatusWidgetState();
}

class _UploadStatusWidgetState extends State<UploadStatusWidget> {
  late Upload upload = widget.upload;
  late int index = widget.index;

  @override
  void initState() {
    timerFunc();
    super.initState();
  }

  timerFunc() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (user.uploads[index].status != 'loading') {
        timer.cancel();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1),
      child: GestureDetector(
        onTap: () {
          if(upload.status == 'error') {
            UploadService.uploadRetry(upload);
            timerFunc();
            setState(() {});
          }
        },
        child: Container(
          height: 90,
          decoration:  BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                topRight: index == 0 ? const Radius.circular(20) : Radius.zero,
                topLeft: index == 0 ? const Radius.circular(20) : Radius.zero,
                bottomRight: index == user.uploads.length - 1 ? const Radius.circular(20) : Radius.zero,
                bottomLeft: index == user.uploads.length - 1 ? const Radius.circular(20) : Radius.zero,
              )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[700],
                            image: upload.media != null ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(upload.media!)
                            ) : null
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(upload.caption ?? '', style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis),),
                            Row(
                              children: [
                                Text(
                                  upload.type == 'geoPost' ? 'Post'
                                      : upload.type == 'storyPost' ? 'Story'
                                      : '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                    upload.status == 'complete' ? ' - Complete'
                                    : upload.status == 'error' ? ' - Error - Tap to try again'
                                        : '',
                                  style: TextStyle(
                                    color: upload.status == 'error'
                                        ? Colors.red
                                        : Colors.grey
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  upload.status == 'loading' ?
                   const LinearProgressIndicator()
                  : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
