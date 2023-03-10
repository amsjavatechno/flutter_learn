import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _timerCount = 0;
  Color _textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_timerCount < 10) {
        setState(() {
          _textColor = _textColor == Colors.black ? Colors.red : Colors.black;
          _timerCount++;
        });
      } else {
        _timer?.cancel();
      }
    });
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/chat');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/verified.svg',
            height: 30,
            width: 30,
            semanticsLabel: 'My Image',
          ),
          Text(
            "OpenAI ChatGPT Verified",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ],
      )),
    );
  }
}
