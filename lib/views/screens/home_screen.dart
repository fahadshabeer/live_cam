import 'package:flutter/material.dart';
import 'package:untitled/views/screens/live_video_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: MaterialButton(
          color: Colors.blue,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>LiveVideoScreen()));
          },
          child: const Text("Open Streaming"),
        ),
      ),
    );
  }
}
