import 'package:dio/dio.dart';


class CategoryApiService {

  final Dio dio;


  CategoryApiService(this.dio);


  Future<List<String>> getCategories() async {

    final response = await dio.get(
      'https://fakestoreapi.com/products/categories',
    );


    return List<String>.from(response.data);

  }

}