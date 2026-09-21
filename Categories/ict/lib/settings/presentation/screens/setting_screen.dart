import 'package:flutter/material.dart';


class SettingsScreen extends StatelessWidget {


  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text("Settings"),

      ),


      body: Column(

        children: [


          SwitchListTile(

            title: const Text("Dark Mode"),

            value: false,

            onChanged: (value){},

          ),



          ListTile(

            leading: const Icon(Icons.logout),

            title: const Text("Logout"),

            onTap: (){},


          )


        ],

      ),

    );


  }


}