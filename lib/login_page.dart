import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_chat_gpt_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _apikeyController = TextEditingController();

  getChatResponse(String message) async {
    var url1 = "https://api.openai.com/v1/completions";
    var auth = 'Bearer $message';
    try {
      var url = Uri.parse(url1);
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
        body:
            '{"model": "text-davinci-003","prompt": "", "max_tokens": 4000, "temperature": 0.1}',
      );
      Constants.prefs = await SharedPreferences.getInstance();
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          Constants.prefs!.setBool("loggedIn", true);
          Constants.prefs!.setString("key", _apikeyController.text);
          Navigator.pushReplacementNamed(context, '/splash');
        });
      } else {
        setState(() {
          _isLoading = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                icon: Icon(Icons.error),
                iconColor: Colors.red,
                iconPadding: EdgeInsets.all(5.0),
                content: Text('Check Your ChatGPT API_KEY!'),
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
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            icon: Icon(Icons.error),
            iconColor: Colors.red,
            iconPadding: EdgeInsets.all(5.0),
            content: Text('Check Your Internet Connection'),
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
      // return "Check_Your_Internet_Connection"
      throw Exception('Failed to connect to ChatGPT API: $e');
    }
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      // form is valid, perform login
      setState(() {
        _isLoading = true;
      });
      // print("Key ${_apikeyController.text}");
      // print(Constants.prefs!.getBool("loggedIn"));
      // print(Constants.prefs!.getString("key"));
      getChatResponse(_apikeyController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatGPT',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan.shade100,
        elevation: 4.0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Card(
                    color: Colors.white,
                    shadowColor: Colors.black.withOpacity(0.4),
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: _apikeyController,
                                decoration: InputDecoration(
                                  labelText: 'Enter ChatGPT API KEY',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.multiline,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'ChatGPT API KEY is required';
                                  }
                                  return null;
                                },
                                // onSaved: (value) {
                                //   _apikey = value!;
                                //   print("Key 1 $value");
                                // },
                              ),
                              SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: _submitForm,
                                child: Text('Login'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
