import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/utils/services/open_camera_repo.dart';

part 'open_camera_state.dart';

class OpenCameraCubit extends Cubit<OpenCameraState> {
  OpenCameraCubit() : super(OpenCameraInitial());
  openCamera()async{
    try{
      emit(OpenCameraLoading());
      await OpenCameraRepo.makeApiCall();
      emit(OpenCameraLoaded());
    }catch(e){
      if(e is SocketException){
        emit(OpenCameraError(err: "Something wrong with your internet connection!"));
      }
      else if(e is HttpException){
        emit(OpenCameraError(err: e.message));
      }
      else {
        emit(OpenCameraError(err: e.toString()));
      }
    }
  }

}
