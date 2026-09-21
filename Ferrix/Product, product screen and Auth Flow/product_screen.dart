import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../data/services/product_api_service.dart';

import 'product_details_screen.dart';



class ProductScreen extends StatefulWidget {


  const ProductScreen({super.key});


  @override
  State<ProductScreen> createState() =>
      _ProductScreenState();

}



class _ProductScreenState extends State<ProductScreen> {


  final ProductApiService api =
  ProductApiService();


  late Future<List<ProductModel>> products;



  @override
  void initState() {

    super.initState();

    products = api.getProducts();

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
          "Products",
        ),

      ),



      body:

      FutureBuilder<List<ProductModel>>(


        future: products,


        builder: (context, snapshot) {



          if(snapshot.connectionState ==
              ConnectionState.waiting) {


            return const Center(

              child:
              CircularProgressIndicator(),

            );


          }



          if(snapshot.hasError) {


            return Center(

              child:
              Text(
                snapshot.error.toString(),
              ),

            );


          }



          if(!snapshot.hasData ||
              snapshot.data!.isEmpty) {


            return const Center(

              child:
              Text(
                "No Products",
              ),

            );


          }



          final productsList =
          snapshot.data!;



          return ListView.builder(


            itemCount:
            productsList.length,


            itemBuilder: (context,index) {



              final product =
              productsList[index];



              return Card(


                child: ListTile(


                  leading:

                  Image.network(

                    product.image,

                    width:60,

                  ),



                  title:

                  Text(
                    product.title,
                  ),



                  subtitle:

                  Text(
                    "${product.price} \$",
                  ),



                  onTap: () {


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            ProductDetailsScreen(

                              product: product,

                            ),

                      ),

                    );


                  },


                ),


              );


            },


          );


        },


      ),


    );


  }


}