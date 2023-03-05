import 'package:flutter/material.dart';
import 'package:ip_geo_lookup/pages/ip_lookup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP Tracker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: IpLookupApp(),
    );
  }
}
