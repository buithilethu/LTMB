import 'package:flutter/material.dart';

class LoadImagesDemo extends StatelessWidget {
  const LoadImagesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load IMAGE demo'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Image.asset('assets/images/1.jpg'),
            ),
            Expanded(
              child: Image.asset('assets/images/2.jpg'),
            ),
            Expanded(
              child: Image.asset('assets/images/3.jpg'),
            ),
          ],
        ),
      ),



    );
  }
}