import '../services/category_api_service.dart';


class CategoryRepository {

  final CategoryApiService apiService;


  CategoryRepository(this.apiService);


  Future<List<String>> getCategories() async {

    return await apiService.getCategories();

  }

}