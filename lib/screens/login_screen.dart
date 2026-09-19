import 'package:flutter/material.dart';

import '../features/product/presentation/screens/product_screen.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();

  final passwordController = TextEditingController();



  void login() {


    final email =
    emailController.text.trim();


    final password =
    passwordController.text.trim();



    if(email.isNotEmpty && password.isNotEmpty){


      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const ProductScreen(),

        ),

      );


    }else{


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Enter email and password",
          ),

        ),

      );


    }


  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "Login",
        ),

      ),



      body: Padding(

        padding:
        const EdgeInsets.all(20),



        child: Column(


          mainAxisAlignment:
          MainAxisAlignment.center,



          children: [


            TextField(

              controller:
              emailController,


              decoration:
              const InputDecoration(

                labelText:
                "Email",

                border:
                OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:20),



            TextField(

              controller:
              passwordController,


              obscureText:true,


              decoration:
              const InputDecoration(

                labelText:
                "Password",

                border:
                OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:30),



            SizedBox(

              width:
              double.infinity,


              child:
              ElevatedButton(


                onPressed:
                login,


                child:
                const Text(
                  "Login",
                ),


              ),

            ),


          ],


        ),

      ),


    );

  }



  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }

}