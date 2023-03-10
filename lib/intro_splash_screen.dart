import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_chat_gpt_app/constants.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
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
      Constants.prefs?.getBool("loggedIn") == true
          ? Navigator.pushReplacementNamed(context, '/chat')
          : Navigator.pushReplacementNamed(context, '/login');
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
            'assets/images/openai.svg',
            height: 30,
            width: 30,
            semanticsLabel: 'My Image',
          ),
          Text(
            "OpenAI ChatGPT",
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
