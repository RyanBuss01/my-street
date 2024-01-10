import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final String url;
  final bool isVideo;
  const MediaPreviewScreen({Key? key, required this.url, required this.isVideo}) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    if(widget.isVideo) {
      _videoPlayerController = VideoPlayerController.network(
        widget.url,
      );
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.setVolume(1.0);
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize();
      _videoPlayerController!.play();
    }
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: SizedBox.expand(
          child:
          widget.isVideo
              ? FutureBuilder(
            future: _initializeVideoPlayerFuture,
                builder: (context, snap) {
              if(snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                );
              }
                  return FittedBox(
                  fit: BoxFit.fitWidth,
                  child: SizedBox(
                      height: _videoPlayerController!.value.size.height,
                      width: _videoPlayerController!.value.size.width,
                      child: VideoPlayer(_videoPlayerController!)
                    )
                  );
                }
              )
              : Image(
                image: NetworkImage(widget.url),
                fit: BoxFit.fitWidth,
              ),
        ),
      ),
    );
  }
}
