import 'package:camera/camera.dart';

class CameraService {
  static getCameraDescriptions() async {
    var cameraDescriptions = await availableCameras();
    return cameraDescriptions;
  }
}