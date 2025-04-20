import 'package:flutter/material.dart';
import 'package:app_image/loads_images/LoadImagesDemo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Sử dụng màn hình LoadImagesDemo thay vì MyHomePage
      home: const LoadImagesDemo(),
    );
  }
}
