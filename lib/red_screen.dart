import 'package:flutter/material.dart';

class RedScreen extends StatelessWidget {

  const RedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: const Center(
          child: Text(
            'Você caiu :(',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      )
    );
  }
}