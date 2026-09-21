import '../../domain/entities/product.dart';


class ProductModel extends Product{


  ProductModel({

    required super.id,
    required super.title,
    required super.image,
    required super.price,
    required super.category,

  });



  factory ProductModel.fromJson(Map<String,dynamic> json){

    return ProductModel(

      id: json['id'],

      title: json['title'],

      image: json['image'],

      price: (json['price']).toDouble(),

      category: json['category'],

    );


  }


}