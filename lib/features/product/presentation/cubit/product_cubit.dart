import 'package:flutter_bloc/flutter_bloc.dart';


import '../../data/repositories/product_repository.dart';

import 'product_state.dart';



class ProductCubit extends Cubit<ProductState>{



  final ProductRepository repository;



  ProductCubit(
      this.repository
      )
      :
        super(ProductInitial());




  Future<void> getProducts() async {


    try{


      emit(ProductLoading());



      final products =
      await repository.getProducts();



      emit(
          ProductSuccess(products)
      );



    }catch(e){


      emit(
          ProductFailure(
              e.toString()
          )
      );


    }


  }



}