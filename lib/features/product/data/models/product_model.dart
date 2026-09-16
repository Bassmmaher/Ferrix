class ProductModel {
  final int id;
  final String title;
  final String image;
  final double price;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
  });


  factory ProductModel.fromJson(Map<String,dynamic> json){
    return ProductModel(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      price: json['price'].toDouble(),
    );
  }
}