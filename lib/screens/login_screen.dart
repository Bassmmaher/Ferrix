import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/theme/cubit/theme_cubit.dart';
import 'home_screen.dart';



class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});


  @override
  State<LoginScreen> createState() => _LoginScreenState();

}



class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();

  final passwordController = TextEditingController();


  bool loading = false;




  void login(){


    if(emailController.text.isEmpty){

      message("Enter your email");

      return;

    }



    if(!emailController.text.contains("@")){

      message("Invalid email");

      return;

    }



    if(passwordController.text.length < 6){

      message("Password must be 6 characters");

      return;

    }



    setState(() {

      loading = true;

    });




    Future.delayed(

      const Duration(seconds: 2),

          (){


        setState(() {

          loading = false;

        });



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) => const HomeScreen(),

          ),

        );


      },

    );


  }






  void message(String text){

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(text),

      ),

    );

  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(



      backgroundColor:

      Theme.of(context).scaffoldBackgroundColor,






      appBar: AppBar(



        backgroundColor: Colors.transparent,

        elevation: 0,





        leading: IconButton(



          onPressed: (){


            Navigator.pop(context);


          },



          icon: const Icon(



            Icons.arrow_back,



            color: Colors.white,



            size: 28,



          ),



        ),






        actions: [



          Padding(



            padding:

            const EdgeInsets.only(right: 10),





            child: Transform.scale(



              scale: 0.8,





              child: Switch(



                value:

                Theme.of(context).brightness == Brightness.dark,





                onChanged: (value){



                  context

                      .read<ThemeCubit>()

                      .changeTheme();



                },





                activeThumbColor: Colors.white,



                activeTrackColor: Colors.blue,





                inactiveThumbColor: Colors.grey,



                inactiveTrackColor: Colors.black26,



              ),



            ),



          ),



        ],



      ),







      body: Center(



        child: Container(



          width: 330,

          height: 500,





          decoration: BoxDecoration(



            borderRadius:

            BorderRadius.circular(15),





            image: const DecorationImage(



              image: AssetImage(

                "assets/images/login.png",

              ),



              fit: BoxFit.cover,



            ),



          ),







          child: Container(



            padding:

            const EdgeInsets.all(20),





            decoration: BoxDecoration(



              borderRadius:

              BorderRadius.circular(15),





              gradient: LinearGradient(



                colors: [



                  Colors.black.withOpacity(.85),



                  Colors.black.withOpacity(.3),



                ],





                begin:

                Alignment.bottomCenter,





                end:

                Alignment.topCenter,



              ),



            ),







            child: Column(



              crossAxisAlignment:

              CrossAxisAlignment.start,





              children: [



                const Spacer(),






                const Text(



                  "Let's Connect With Us!",





                  style: TextStyle(



                    color: Colors.white,



                    fontSize: 22,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),







                const SizedBox(height:25),







                TextField(



                  controller: emailController,





                  style: const TextStyle(

                    color: Colors.white,

                  ),





                  decoration:

                  input("Email Address"),



                ),






                const SizedBox(height:15),







                TextField(



                  controller: passwordController,





                  obscureText: true,





                  style: const TextStyle(

                    color: Colors.white,

                  ),





                  decoration:

                  input("Password"),



                ),







                Align(



                  alignment:

                  Alignment.centerRight,





                  child: const Text(



                    "Forgot password?",





                    style: TextStyle(



                      color: Colors.grey,



                    ),



                  ),



                ),






                const SizedBox(height:20),







                SizedBox(



                  width: double.infinity,



                  height:45,







                  child: ElevatedButton(



                    style:

                    ElevatedButton.styleFrom(



                      backgroundColor:

                      Colors.blue,





                      shape:

                      RoundedRectangleBorder(



                        borderRadius:

                        BorderRadius.circular(25),



                      ),



                    ),







                    onPressed:

                    loading ? null : login,







                    child:

                    loading



                        ? const CircularProgressIndicator(



                      color: Colors.white,

                    )



                        : const Text(



                      "Login",





                      style:

                      TextStyle(



                        color: Colors.white,



                      ),



                    ),



                  ),



                ),





              ],



            ),



          ),



        ),



      ),



    );


  }







  InputDecoration input(String text){



    return InputDecoration(



      hintText: text,



      hintStyle:

      const TextStyle(

        color: Colors.grey,

      ),





      filled: true,



      fillColor:

      Colors.white12,





      border:

      OutlineInputBorder(



        borderRadius:

        BorderRadius.circular(8),



      ),



    );



  }



}