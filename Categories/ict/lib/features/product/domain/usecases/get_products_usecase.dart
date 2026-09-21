import '../entities/product.dart';
import '../repositories/product_repository.dart';


class GetProductsUseCase {


  final ProductRepository repository;


  GetProductsUseCase(this.repository);



  Future<List<Product>> call(){

    return repository.getProducts();

  }


}