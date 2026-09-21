import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_products_usecase.dart';

import 'product_state.dart';



class ProductCubit extends Cubit<ProductState>{


  final GetProductsUseCase getProductsUseCase;



  ProductCubit(
      this.getProductsUseCase
      )
      :
        super(ProductInitial());




  Future<void> getProducts() async{


    try{


      emit(ProductLoading());



      final products =
      await getProductsUseCase();



      emit(
          ProductSuccess(products)
      );



    }catch(e){


      emit(
          ProductError(
              e.toString()
          )
      );


    }



  }



}