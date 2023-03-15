import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
part 'upload_selfie_event.dart';
part 'upload_selfie_state.dart';

class UploadSelfieBloc extends Bloc<UploadSelfieEvent, UploadSelfieState> {
  List<CameraDescription> cameras = [];

  late CameraController controller;

  var isFlashOn = false;

  UploadSelfieBloc() : super(UploadSelfieLoadingViewState()) {
    _initController();
    _handleEvents();
  }

  void _handleEvents() {
    on<UploadSelfieEvent>((event, emit) {
      if (event is UploadSelfieControllerReadyEvent) {
        emit(UploadSelfieInitial());
      } else if (event is UploadSelfieFlashChangeEvent) {
        isFlashOn = !isFlashOn;
        emit(UploadSelfieInitial());
      }
    });
  }

  void _initController() async {
    cameras = await availableCameras();
    // To display the current output from the Camera,
    // create a CameraController.
    controller = CameraController(
        // Get a specific camera from the list of available cameras.
        cameras.first,
        // Define the resolution to use.
        ResolutionPreset.medium,
        enableAudio: false);

    // Next, initialize the controller. This returns a Future.
    await controller.initialize();
    add(UploadSelfieControllerReadyEvent());
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }

  void clickPicture() async {
    try {
      await controller.pausePreview();

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await controller.takePicture();

      debugPrint(image.path);

      await controller.resumePreview();
    } catch (e) {
      // If an error occurs, log the error to the console.
      //print(e);
    }
  }
}
