import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:untitled/cubits/%20controllers/open_camera_cubit/open_camera_cubit.dart';

class LiveVideoScreen extends StatefulWidget {
  const LiveVideoScreen({super.key});

  @override
  _LiveVideoScreenState createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {

  late VlcPlayerController _vlcViewController;
  bool iconLoaded = false;
  bool isFullScreen = false;
  MapType _currentMapType = MapType.normal;
  bool _isBuffering = true;
  bool _isPlaying = false;
  String? _errorMessage;

  final LatLng _center = const LatLng(21.2514, 81.6296); // Raipur, Chhattisgarh

  @override
  void initState() {
    context.read<OpenCameraCubit>().openCamera();
    super.initState();
    _vlcViewController = VlcPlayerController.network(
      'http://gps.markongps.com:8881/live/0/864993060098960.flv',
      autoPlay: true,
      autoInitialize: true,
      hwAcc: HwAcc.auto, // Hardware acceleration
      options: VlcPlayerOptions(
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        advanced: VlcAdvancedOptions(
         [
           VlcAdvancedOptions.liveCaching(1000),
           VlcAdvancedOptions.networkCaching(1000),
         ]
        ),
      ),
    )..addListener(_onVlcPlayerControllerUpdated);
  }

  @override
  void dispose() {
    _vlcViewController.removeListener(_onVlcPlayerControllerUpdated);
    if(_vlcViewController.value.isInitialized){
      _vlcViewController.dispose();
    }
    super.dispose();
  }

  void _onVlcPlayerControllerUpdated() {
    final playerValue = _vlcViewController.value;

    if (playerValue.isInitialized && _isBuffering) {
      setState(() {
        _isBuffering = false;
        _isPlaying = true;
      });
    }

    if (playerValue.hasError) {
      print('Error: ${playerValue.errorDescription}');
      setState(() {
        _isPlaying = false;
        _errorMessage = 'Error playing video: ${playerValue.errorDescription}';
      });
      return; // Early exit on error
    }

    setState(() {
      _isBuffering = playerValue.isBuffering;
    });

    // Additional logging for debugging
    print('VLC Player Status: '
        'isInitialized=${playerValue.isInitialized}, '
        'isPlaying=${playerValue.isPlaying}, '
        'isBuffering=${playerValue.isBuffering}, '
        'position=${playerValue.position}, '
        'duration=${playerValue.duration}, '
        'buffering=${playerValue.isBuffering}');
  }


  void _toggleMapType() {
    setState(() {
      _currentMapType = (_currentMapType == MapType.normal)
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullScreen
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_arrow_left),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: const Color(0xFF5D3FD3),
              title: const Text(
                'Live Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_arrow_left),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Color(0xFF5D3FD3),
              title: const Text(
                'Live Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      body:  Column(
        children: [
          Expanded(
            flex: isFullScreen ? 1 : 2,
            child: Container(
              color: Color(0xFF5D3FD3),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: BlocConsumer<OpenCameraCubit, OpenCameraState>(
                        listener: (context, state) async {
                          if (state is OpenCameraLoaded) {
                            if (mounted) {
                              setState(() {});
                            }
                          }
                          if (state is OpenCameraError) {
                            Fluttertoast.showToast(
                                msg: state.err,
                                backgroundColor: Colors.red);
                          }
                        },
                        builder: (context, state) {
                          return Stack(
                            children: [
                              (state is OpenCameraLoading)
                                  ? AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Center(
                                  child: Text(
                                    "Initializing camera",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp),
                                  ),
                                ),
                              )
                                  : (state is OpenCameraError)
                                  ? MaterialButton(
                                color: Colors.white,
                                onPressed: () {
                                  context
                                      .read<OpenCameraCubit>()
                                      .openCamera();
                                },
                                child: const Text("Retry"),
                              )
                                  : VlcPlayer(
                                controller: _vlcViewController,
                                aspectRatio: 16 / 9,
                                placeholder: const Center(
                                    child:
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    )),
                              ),
                              if (_isBuffering || !_isPlaying)
                                Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      if (_errorMessage != null)
                                        Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Loading video...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (!isFullScreen)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon:
                            const Icon(Icons.volume_up, color: Colors.white),
                            onPressed: () {},
                          ),
                          const Icon(Icons.camera_alt, color: Colors.white),
                          const Icon(Icons.mic, color: Colors.white),
                          const Icon(Icons.videocam, color: Colors.white),
                          GestureDetector(
                            onTap: _toggleFullScreen,
                            child:
                            const Icon(Icons.fullscreen, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!isFullScreen)
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
        ],
      ),
    );
  }
}
