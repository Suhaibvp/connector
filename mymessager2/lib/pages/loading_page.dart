import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation_ll9tefh4.json',
              // width: 500,
              height: 856,
              fit: BoxFit.fill,
            ),
            // You can keep the CircularProgressIndicator
          ],
        ),
      ),
    );
  }
}
