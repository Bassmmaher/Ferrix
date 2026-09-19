import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'screens/login_screen.dart';


import 'features/product/data/services/product_api_service.dart';
import 'features/product/data/repositories/product_repository.dart';

import 'features/product/presentation/cubit/product_cubit.dart';



void main() {


  final productApiService = ProductApiService();


  final productRepository =
  ProductRepository(
    productApiService,
  );


  runApp(

    MultiBlocProvider(

      providers: [

        BlocProvider(
          create: (_) =>
          ProductCubit(
            productRepository,
          )
            ..getProducts(),
        ),

      ],


      child: const MyApp(),

    ),

  );

}



class MyApp extends StatelessWidget {


  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {


    return MaterialApp(

      debugShowCheckedModeBanner: false,


      home: const LoginScreen(),

    );

  }
}