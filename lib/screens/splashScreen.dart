import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'homepage.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    moveToNext();
  }

  @override
  void dispose() {
    super.dispose();
  }

  moveToNext() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/homepage', (Route<dynamic> route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('lib/lotties/github_loader.json'),
            Text('GITHUB SEARCHER',
                style: TextStyle(
                  letterSpacing: 2,
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                )),
          ],
        )),
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
