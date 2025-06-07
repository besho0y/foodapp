import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    // Add timeout to prevent long loading times
    Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        _checkUserAuth();
      }
    });
  }

  void _initializeVideo() async {
    try {
      controller = VideoPlayerController.asset('assets/startup/startup.mp4');
      await controller!.initialize();

      if (mounted) {
        setState(() {});
        controller!.setLooping(false);
        controller!.setVolume(0.0);
        controller!.play();

        // Listen for video completion
        controller!.addListener(_onVideoStatusChanged);
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      // If video fails, proceed to authentication immediately
      Timer(const Duration(seconds: 1), () {
        if (!_hasNavigated) {
          _checkUserAuth();
        }
      });
    }
  }

  void _onVideoStatusChanged() {
    if (controller != null &&
        controller!.value.isInitialized &&
        controller!.value.position >= controller!.value.duration &&
        controller!.value.duration.inMilliseconds > 0 &&
        !_hasNavigated) {
      _checkUserAuth();
    }
  }

  void _checkUserAuth() async {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;

      // Check if user is logged in
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User is logged in, get user data
        ProfileCubit.get(context).getuserdata();
      }

      // Navigate everyone to layout - authentication will be handled in specific screens
      navigateAndFinish(context, const Layout());
    }
  }

  // For development and testing purposes
  void _goToAdminPanel() {
    navigateAndFinish(context, const AdminPanelScreen());
  }

  @override
  void dispose() {
    controller?.removeListener(_onVideoStatusChanged);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 227, 189, 1.0),
      body: Center(
        child: controller != null && controller!.value.isInitialized
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: controller!.value.size.width,
                    height: controller!.value.size.height,
                    child: VideoPlayer(controller!),
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                color: Colors.transparent,
              ),
      ),
    );
  }
}
