class ProductModel {

  final int id;
  final String title;
  final String description;
  final String category;
  final String image;
  final double price;


  ProductModel({

    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.price,

  });



  factory ProductModel.fromJson(Map<String,dynamic> json){

    return ProductModel(

      id: json['id'],

      title: json['title'],

      description: json['description'],

      category: json['category'],

      image: json['image'],

      price: (json['price'] as num).toDouble(),

    );

  }

}