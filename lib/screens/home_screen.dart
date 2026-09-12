import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Home"),
      ),

      body: const Center(

        child: Text(

          "Login Successfully",

          style: TextStyle(

            fontSize: 25,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

    );

  }

}