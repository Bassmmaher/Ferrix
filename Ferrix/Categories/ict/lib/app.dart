import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

import 'core/theme/theme_cubit.dart';



class MyApp extends StatelessWidget{


  const MyApp({super.key});



  @override
  Widget build(BuildContext context){



    return BlocBuilder<ThemeCubit,bool>(


      builder:(context,isDark){


        return MaterialApp(


          debugShowCheckedModeBanner:false,


          theme:

          isDark

              ?

          AppTheme.dark

              :

          AppTheme.light,



          home:

          const HomeScreen(),



        );


      },


    );



  }


}