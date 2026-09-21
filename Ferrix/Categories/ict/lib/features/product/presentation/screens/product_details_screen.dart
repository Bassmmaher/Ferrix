
import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';



class ProductDetailsScreen extends StatelessWidget {


  final Product product;



  const ProductDetailsScreen({

    super.key,

    required this.product,

  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(

          "Product Details",

        ),

      ),



      body: Padding(


        padding: const EdgeInsets.all(20),



        child: Column(


          crossAxisAlignment: CrossAxisAlignment.start,



          children: [



            Center(


              child: Image.network(


                product.image,


                height: 250,


              ),


            ),



            const SizedBox(height: 20),




            Text(


              product.title,


              style: const TextStyle(


                fontSize: 22,


                fontWeight: FontWeight.bold,


              ),


            ),




            const SizedBox(height: 15),




            Text(


              "\$ ${product.price}",


              style: const TextStyle(


                fontSize: 20,


              ),


            ),




          ],


        ),


      ),


    );


  }


}