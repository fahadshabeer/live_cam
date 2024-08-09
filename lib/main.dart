import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:untitled/cubits/%20controllers/open_camera_cubit/open_camera_cubit.dart';
import 'package:untitled/views/screens/home_screen.dart';

import 'views/screens/live_video_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context)=>OpenCameraCubit())
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home:  HomeScreen(),
        ),
      ),
    );
  }
}


