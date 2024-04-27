import 'package:flutter/material.dart';

import 'map_screen.dart';

void main(){
  return runApp(const MyMap());
}
class MyMap extends StatelessWidget {
  const MyMap({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

