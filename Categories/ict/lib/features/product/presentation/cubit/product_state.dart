import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';


abstract class ProductState extends Equatable {

  @override
  List<Object?> get props => [];

}


// Initial

class ProductInitial extends ProductState {}


// Loading

class ProductLoading extends ProductState {}


// Success

class ProductSuccess extends ProductState {

  final List<Product> products;


  ProductSuccess(this.products);


  @override
  List<Object?> get props => [products];

}


// Error

class ProductError extends ProductState {

  final String message;


  ProductError(this.message);


  @override
  List<Object?> get props => [message];

}