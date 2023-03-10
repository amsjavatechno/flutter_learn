// -*- coding: utf-8 -*-
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:new_chat_gpt_app/char_response.dart';
import 'package:new_chat_gpt_app/constants.dart';
// import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textEditingController = TextEditingController();
  // List<String> _messages = [];
  List<ChatResponse> _messages = [];
  String? apikey = "123";
  bool isApiHitSuccess = false;
  bool isLoading = false;
  FocusNode _focusNode = FocusNode();
  int chatIndex = 0;

  //used to send Messages
  void _sendMessage() async {
    String message = _textEditingController.text;
    // List<int> message = utf8.encode(message1);
    // print(message.toString());
    ChatResponse msg = ChatResponse(null, null, 0, null, null,
        [Choices(Message("user", message), null, 0)]);

    if (message.isNotEmpty) {
      setState(() {
        _messages.insert(0, msg);
        chatIndex = 0;
      });
      ChatResponse response =
          await getChatResponse(_formatInput(message.toString()));
      setState(() {
        _messages.insert(0, response);
        isLoading = false;
        chatIndex = 1;
      });
      _textEditingController.clear();
    }
  }

  //get gpt Response

  final String endpoint = 'https://api.openai.com/v1/chat/completions';
  // final String apiKey1 = 'api';
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${Constants.prefs!.getString("key")}'
  };

  Future<ChatResponse> getChatResponse(String message) async {
    isLoading = true;
    final body = {
      'temperature': 0.7,
      'max_tokens': 4000,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0,
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "user",
          "content": message,
        },
      ],
    };
    try {
      final response = await http.post(Uri.parse(endpoint),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        isApiHitSuccess = true;
        // return jsonDecode(response.body)['choices'][0]['text'];
        return ChatResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        print(response.statusCode);
        print("body ${response.body}");
        setState(() {
          isLoading = false;
        });
        isApiHitSuccess = true;
        // return "Please Try Again !";
        throw Exception('Failed to get chat response');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            icon: Icon(Icons.error),
            iconColor: Colors.red,
            iconPadding: EdgeInsets.all(5.0),
            content: Text('Check Your Internet Connection!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      isApiHitSuccess = false;
      setState(() {
        isLoading = false;
      });
      // _messages.insert(0, "INTERNET_CONNECTION_ERROR");
      throw Exception('Failed to connect to ChatGPT API: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // var _focusNode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatGPT',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Constants.prefs!.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: Icon(Icons.exit_to_app_sharp),
              color: Colors.pink),
        ],
        backgroundColor: Colors.cyan.shade100,
        elevation: 4.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: UniqueKey(),
              // key : ,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                // print(_messages[index].content?.isNotEmpty);
                dynamic res = _messages[index]
                    .choices?[0]
                    .message
                    ?.content
                    .toString()
                    .trim();
                bool isUser =
                    _messages[index].choices?[0].message?.role.toString() ==
                        "user";
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    elevation: 4.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: ListTile(
                      leading: isUser
                          ? Icon(
                              Icons.person_2_sharp,
                              color: Colors.purple,
                            )
                          : Icon(
                              Icons.chat_bubble,
                              color: Colors.pinkAccent,
                            ),
                      // title: Text(
                      //     "${}"),
                      title: (isUser)
                          ? SelectableText(
                              res,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )
                          : (index == 0)
                              ? AnimatedTextKit(
                                  repeatForever: false,
                                  isRepeatingAnimation: false,
                                  totalRepeatCount: 1,
                                  displayFullTextOnTap: true,
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      res,
                                    )
                                  ],
                                )
                              : SelectableText(
                                  res,
                                  enableInteractiveSelection: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                      // tileColor: Colors.lightGreen.shade100,
                    ),
                  ),
                );
              },
            ),
          ),
          (isLoading) ? _loading() : SizedBox(height: 5),

          // ,
          SizedBox(
            height: 10,
          ),
          Container(
            // padding: EdgeInsets.symmetric(horizontal: 16.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

            // color: Color.fromARGB(255, 245, 244, 230),
            color: Colors.cyan.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    // constraints: BoxConstraints(maxHeight: 30),
                    child: SingleChildScrollView(
                      child: TextField(
                        focusNode: _focusNode,
                        maxLines: null,
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Type your message',
                          fillColor: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    isApiHitSuccess = false;
                    _focusNode.unfocus();
                    String jsonData = json.encode(_textEditingController.text);
                    print("formatter ${_formatInput(jsonData)}");
                    // dynamic decodedData = json.decode(jsonData);
                    print(jsonData);
                    _sendMessage();
                    _textEditingController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatInput(String input) {
    List<String> lines = input.split('\n');
    String formatted = lines.join(' ');
    return formatted;
  }
}

class _loading extends StatelessWidget {
  const _loading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: LoadingAnimationWidget.prograssiveDots(
      // leftDotColor: const Color(0xFF1A1A3F),
      color: Colors.purpleAccent,
      // rightDotColor: const Color(0xFFEA3799),
      size: 50,
    ));
  }
}
