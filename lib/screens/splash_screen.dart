import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
            'https://www.nicepng.com/png/full/11-111341_nike-orange-nike-logo-png.png'),
      ),
    );
  }
}
