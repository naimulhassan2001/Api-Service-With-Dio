

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  String? image;

  uploadImage() async {
    if (image == null) {
      print("No image selected!");
      return;
    }

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image!, filename: "naimul.png"),
      "name" : "naimul Hassan"
    });

    var headers = {"Content-Type": "multipart/form-data"};

    var response = await ApiService.postApi(
      "https://api.escuelajs.co/api/v1/files/upload",
      formData,
      header: headers,
    );

    print("Upload Response: ${response.message}");
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? xFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      image = xFile.path;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Run blockUI in a separate isolate

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (image != null)
                Image.file(
                  File(image!),
                  height: 200,
                  width: 200,
                ),
              TextButton(
                  onPressed: pickImage,
                  child: Text("Get Image")),
              TextButton(
                  onPressed: uploadImage,
                  child: Text("Upload")),
            ],
          ),
        ),
      ),
    );
  }
}
