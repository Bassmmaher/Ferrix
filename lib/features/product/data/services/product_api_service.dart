import 'package:dio/dio.dart';

import '../models/product_model.dart';



class ProductApiService {


  final Dio dio = Dio();



  Future<List<ProductModel>> getProducts() async {


    final response = await dio.get(
      "https://fakestoreapi.com/products",
    );


    List data = response.data;


    return data
        .map(
          (item)=> ProductModel.fromJson(item),
    )
        .toList();


  }


}