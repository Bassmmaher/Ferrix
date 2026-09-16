import 'package:flutter/material.dart';
import 'login_screen.dart';


class ExploreScreen extends StatelessWidget {

  const ExploreScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff64758D),


      body: Center(

        child: Container(

          width: 330,

          height: 500,

          padding: const EdgeInsets.all(20),


          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(15),

          ),



          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,


            children: [


              const Text(

                "Explore now",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight: FontWeight.bold,

                ),

              ),



              const SizedBox(height: 8),



              const Text(

                "Join us today.",

                style: TextStyle(

                  fontSize: 16,

                ),

              ),



              const SizedBox(height: 35),



              socialButton(

                "Sign up with Google",

                "assets/images/google.png",

              ),



              const SizedBox(height: 15),



              socialButton(

                "Sign up with Apple",

                "assets/images/apple.png",

              ),



              const Spacer(),



              SizedBox(

                width: double.infinity,

                height: 45,


                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.blue,


                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(25),

                    ),

                  ),



                  onPressed: (){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context)=> const LoginScreen(),

                      ),

                    );


                  },



                  child: const Text(

                    "Create account",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 16,

                    ),

                  ),


                ),

              ),


            ],

          ),

        ),

      ),

    );

  }





  Widget socialButton(String text, String image){


    return Container(

      height: 45,


      width: double.infinity,


      decoration: BoxDecoration(

        border: Border.all(

          color: Colors.grey.shade300,

        ),


        borderRadius: BorderRadius.circular(10),

      ),



      child: Row(

        mainAxisAlignment: MainAxisAlignment.center,


        children: [



          Image.asset(

            image,

            width: 20,

            height: 20,


            errorBuilder: (context,error,stackTrace){

              return const Icon(

                Icons.image_not_supported,

                size:20,

              );

            },


          ),



          const SizedBox(width:10),



          Flexible(

            child: Text(

              text,


              overflow: TextOverflow.ellipsis,


              style: const TextStyle(

                fontSize:14,

              ),

            ),

          ),



        ],


      ),


    );


  }


}