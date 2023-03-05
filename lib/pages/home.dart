import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _data = [];
  Future<List<dynamic>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      setState(() {
        _data = json.decode(response.body);
      });
      return _data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (BuildContext context, int index) {
          print("hi");
          return ListTile(
            title: Text(_data[index]['title']),
            subtitle: Text(_data[index]['body']),
          );
        },
      ),
    );
  }
}
