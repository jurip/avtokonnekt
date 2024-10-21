import 'dart:io';

import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  final String url;
  ImageScreen(this.url);

  @override
  _MyImageScreen createState() => _MyImageScreen(url);
}

class _MyImageScreen extends State<ImageScreen> {
  final String url;
  _MyImageScreen(this.url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Фото'),
        ),
        body: Image.file(File(url), width: double.infinity));
  }
}