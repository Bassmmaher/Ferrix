import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';


class CategoryScreen extends StatelessWidget {

  const CategoryScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Categories"),

      ),


      body: BlocBuilder<CategoryCubit, CategoryState>(

        builder: (context, state) {


          if (state is CategoryLoading) {

            return const Center(

              child: CircularProgressIndicator(),

            );

          }


          if (state is CategorySuccess) {

            return ListView.builder(

              itemCount: state.categories.length,

              itemBuilder: (context, index) {

                final category =
                state.categories[index];


                return Card(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),


                  child: ListTile(

                    leading: const Icon(
                      Icons.category,
                    ),


                    title: Text(
                      category,
                    ),


                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),

                  ),

                );

              },

            );

          }


          if (state is CategoryError) {

            return Center(

              child: Text(
                state.message,
              ),

            );

          }


          return const SizedBox();

        },

      ),

    );

  }

}