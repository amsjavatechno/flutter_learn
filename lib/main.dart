import 'package:flutter/material.dart';
import 'package:new_chat_gpt_app/chat_gpt_home.dart';
import 'package:new_chat_gpt_app/constants.dart';
import 'package:new_chat_gpt_app/intro_splash_screen.dart';
import 'package:new_chat_gpt_app/login_page.dart';
import 'package:new_chat_gpt_app/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Constants.prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // useMaterial3: true,
        primarySwatch: Colors.purple,
      ),
      home: WelcomeSplashScreen(),
      routes: {
        "/login": (context) => LoginForm(),
        "/chat": (context) => ChatScreen(),
        "/splash": (context) => SplashScreen(),
      },
    );
  }
}
