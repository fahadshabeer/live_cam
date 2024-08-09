part of 'open_camera_cubit.dart';


abstract class OpenCameraState {}

class OpenCameraInitial extends OpenCameraState {}
class OpenCameraLoading extends OpenCameraState {}
class OpenCameraLoaded extends OpenCameraState {}
class OpenCameraError extends OpenCameraState {
  String err;
  OpenCameraError({required this.err});
}
