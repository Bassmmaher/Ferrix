import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

import '../models/product_model.dart';
import '../services/product_api_service.dart';


class ProductRepositoryImpl implements ProductRepository {


  final ProductApiService api;


  ProductRepositoryImpl(this.api);



  @override
  Future<List<Product>> getProducts() async {


    final data = await api.getProducts();


    return data
        .map(
            (e)=> ProductModel.fromJson(e)
    )
        .toList();


  }


}
