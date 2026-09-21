import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import 'product_details_screen.dart';



class Product_Screen extends StatelessWidget {


  const Product_Screen({

    super.key,

  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(

          "Products",

        ),

      ),



      body: BlocBuilder<ProductCubit, ProductState>(


        builder: (context, state) {



          if (state is ProductLoading) {


            return const Center(

              child: CircularProgressIndicator(),

            );


          }



          if (state is ProductSuccess) {


            return ListView.builder(


              itemCount: state.products.length,


              itemBuilder: (context, index) {


                final product = state.products[index];



                return Card(


                  child: ListTile(


                    leading: Image.network(

                      product.image,

                      width: 50,

                    ),



                    title: Text(

                      product.title,

                    ),



                    subtitle: Text(

                      "${product.price}",

                    ),



                    onTap: () {


                      Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder: (_) => ProductDetailsScreen(

                            product: product,

                          ),


                        ),


                      );


                    },


                  ),


                );


              },


            );


          }




          if (state is ProductError) {


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