import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/category_repository.dart';
import 'category_state.dart';


class CategoryCubit extends Cubit<CategoryState> {

  final CategoryRepository repository;


  CategoryCubit(this.repository)
      : super(CategoryInitial());


  Future<void> getCategories() async {

    emit(CategoryLoading());


    try {

      final categories =
      await repository.getCategories();


      emit(CategorySuccess(categories));

    } catch (e) {

      emit(CategoryError(e.toString()));

    }

  }

}