abstract class CategoryState {}


class CategoryInitial extends CategoryState {}


class CategoryLoading extends CategoryState {}


class CategorySuccess extends CategoryState {

  final List<String> categories;


  CategorySuccess(this.categories);

}


class CategoryError extends CategoryState {

  final String message;


  CategoryError(this.message);

}