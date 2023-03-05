import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage1 extends StatelessWidget {
  Future<List<dynamic>> fetchData() async {
    final response =
        await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter FutureBuilder Example'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchData(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(snapshot.data![index]['title']),
                    subtitle: Text(snapshot.data![index]['body']),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
