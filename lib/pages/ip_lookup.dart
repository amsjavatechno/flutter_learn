import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IpLookupApp extends StatefulWidget {
  const IpLookupApp({super.key});

  @override
  State<IpLookupApp> createState() => _IpLookupAppState();
}

class _IpLookupAppState extends State<IpLookupApp> {
  final _usernameController = TextEditingController();
  String? ip = "24.48.0.1";
  @override
  void dispose() {
    _usernameController.dispose();

    super.dispose();
  }

  bool _showText = false;

  void _submitForm() {
    ip = _usernameController.text;
    print("ip $ip");
    // List<dynamic> list= fetchData(ip);
    _usernameController.clear();
    setState(() {
      _showText = true;
      fetchData(ip!);
    });
  }

  // List<dynamic> _data = [];

  //fetch data from api
  Future<IpModel> fetchData(String ip) async {
    // List<dynamic> list = [];
    final response = await http.get(Uri.parse('http://ip-api.com/json/$ip'));
    if (response.statusCode == 200) {
      // print("IP CALLED ${json.decode(response.body)}");
      // print("IPMODEL RETURN ${IpModel.fromJson(json.decode(response.body))}");
      return IpModel.fromJson(json.decode(response.body));
    } else {
      // print("SOmething went wrong");
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(ip!);
    // print("----------");
    // print(_data[0]["status"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 244, 230),
      appBar: AppBar(
        title: Text("IpTracker"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "IP Tracker",
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            TextFormField(
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter IP Address';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Enter IP Address',
                hintText: "Enter IP Address",
                border: OutlineInputBorder(),
                fillColor: Colors.black,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
            SizedBox(
              height: 20,
            ),
            if (_showText)
              FutureBuilder<IpModel>(
                future: fetchData(ip!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.home_filled,
                              color: Colors.green.shade900,
                            ),
                            title: Text(
                              "Country : ${snapshot.data!.country}",
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_city,
                                color: Colors.green.shade900),
                            title: Text(
                              "City : ${snapshot.data!.city}",
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading:
                                Icon(Icons.home, color: Colors.green.shade900),
                            title: Text(
                              "Region Name : ${snapshot.data!.regionName}",
                              style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.network_cell,
                                color: Colors.green.shade900),
                            title: Text(
                              "Service Provider : ${snapshot.data!.org}",
                              style: TextStyle(
                                color: Colors.green.shade900,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
          ]),
        ),
      ),
    );
  }
}

class IpModel {
  String? query;
  String? status;
  String? country;
  String? countryCode;
  String? region;
  String? regionName;
  String? city;
  String? zip;
  double? lat;
  double? lon;
  String? timezone;
  String? isp;
  String? org;
  String? as;

  IpModel(
      {this.query,
      this.status,
      this.country,
      this.countryCode,
      this.region,
      this.regionName,
      this.city,
      this.zip,
      this.lat,
      this.lon,
      this.timezone,
      this.isp,
      this.org,
      this.as});

  IpModel.fromJson(Map<String, dynamic> json) {
    query = json['query'];
    status = json['status'];
    country = json['country'];
    countryCode = json['countryCode'];
    region = json['region'];
    regionName = json['regionName'];
    city = json['city'];
    zip = json['zip'];
    lat = json['lat'];
    lon = json['lon'];
    timezone = json['timezone'];
    isp = json['isp'];
    org = json['org'];
    as = json['as'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['query'] = this.query;
    data['status'] = this.status;
    data['country'] = this.country;
    data['countryCode'] = this.countryCode;
    data['region'] = this.region;
    data['regionName'] = this.regionName;
    data['city'] = this.city;
    data['zip'] = this.zip;
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['timezone'] = this.timezone;
    data['isp'] = this.isp;
    data['org'] = this.org;
    data['as'] = this.as;
    return data;
  }
}
