import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'services/api_service.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    apiCall();
    super.initState();
  }

  apiCall() async {
    var body = {"name": "morpheus", "job": "leader"};

    var response =
    await ApiService.postApi("https://reqres.in/api/users", body);

    print(response.statusCode);
    print(response.body);
    print(response.message);
  }

  @override
  Widget build(BuildContext context) {
    // Run blockUI in a separate isolate

    return MaterialApp(
      home: Scaffold(
        body: Text("Api Service With Dio"),
      ),
    );
  }
}
