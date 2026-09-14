import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'core/theme/app_theme.dart';
import 'features/theme/cubit/theme_cubit.dart';
import 'features/theme/cubit/theme_state.dart';

import 'screens/explore_screen.dart';



void main() {


  runApp(

    BlocProvider(

      create: (context)=> ThemeCubit(),

      child: const MyApp(),

    ),

  );


}





class MyApp extends StatelessWidget {


  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {


    return BlocBuilder<ThemeCubit, ThemeState>(


      builder: (context,state){



        return MaterialApp(


          debugShowCheckedModeBanner: false,


          theme: AppTheme.lightTheme,


          darkTheme: AppTheme.darkTheme,



          themeMode:

          state.isDark

              ? ThemeMode.dark

              : ThemeMode.light,



          home: const ExploreScreen(),


        );



      },

    );


  }


}