import 'package:flutter/material.dart';

import '../categories/presentation/screens/categories_screen.dart';
import '../features/product/presentation/screens/product_screen.dart';
import '../settings/presentation/screens/setting_screen.dart';



class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();

}



class _HomeScreenState extends State<HomeScreen> {


  int currentIndex = 0;



  final List<Widget> screens = [


    const CategoryScreen(),


    const Product_Screen(),


    const SettingsScreen(),


  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: screens[currentIndex],



      bottomNavigationBar: BottomNavigationBar(


        currentIndex: currentIndex,


        onTap: (index){


          setState(() {


            currentIndex = index;


          });


        },


        items: const [


          BottomNavigationBarItem(

            icon: Icon(Icons.category),

            label: "Categories",

          ),



          BottomNavigationBarItem(

            icon: Icon(Icons.shopping_cart),

            label: "Products",

          ),



          BottomNavigationBarItem(

            icon: Icon(Icons.settings),

            label: "Settings",

          ),


        ],


      ),


    );


  }


}