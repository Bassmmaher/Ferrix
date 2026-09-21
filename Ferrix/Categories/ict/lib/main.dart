import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import 'app.dart';

import 'core/theme/theme_cubit.dart';

// Product
import 'features/product/data/services/product_api_service.dart';
import 'features/product/data/repositories/product_repository_impl.dart';
import 'features/product/domain/usecases/get_products_usecase.dart';
import 'features/product/presentation/cubit/product_cubit.dart';

// Category
import 'categories/data/services/category_api_service.dart';
import 'categories/data/repositories/category_repository.dart';
import 'categories/presentation/cubit/category_cubit.dart';



void main() {


  // ================= PRODUCT =================

  final productApiService =
  ProductApiService();


  final productRepository =
  ProductRepositoryImpl(
    productApiService,
  );


  final getProducts =
  GetProductsUseCase(
    productRepository,
  );



  // ================= CATEGORY =================

  final categoryApiService =
  CategoryApiService(
    Dio(),
  );


  final categoryRepository =
  CategoryRepository(
    categoryApiService,
  );



  // ================= RUN APP =================

  runApp(


    MultiBlocProvider(


      providers: [


        // Theme

        BlocProvider(

          create: (context) =>
              ThemeCubit(),

        ),



        // Products

        BlocProvider(

          create: (context) =>
          ProductCubit(
            getProducts,
          )
            ..getProducts(),

        ),



        // Categories

        BlocProvider(

          create: (context) =>
          CategoryCubit(
            categoryRepository,
          )
            ..getCategories(),

        ),


      ],


      child: const MyApp(),


    ),


  );


}