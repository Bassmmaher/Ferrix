class ProductScreen extends StatefulWidget {

  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState()=>_ProductScreenState();

}



class _ProductScreenState extends State<ProductScreen>{


  late Future<List<ProductModel>> products;


  final service = ProductApiService();



  @override
  void initState(){

    super.initState();

    products = service.getProducts();

  }



  @override
  Widget build(BuildContext context){


    return Scaffold(

        body:

        FutureBuilder<List<ProductModel>>(

            future: products,


            builder:(context,snapshot){


              if(snapshot.connectionState ==
                  ConnectionState.waiting){

                return Center(
                    child:CircularProgressIndicator()
                );

              }



              if(snapshot.hasError){

                return Center(
                    child:Text("Error")
                );

              }



              final data = snapshot.data!;



              return ListView.builder(

                  itemCount:data.length,


                  itemBuilder:(context,index){


                    final product=data[index];


                    return ListTile(

                      leading:Image.network(product.image),

                      title:Text(product.title),

                      subtitle:
                      Text("\$${product.price}"),

                    );


                  });


            }


        )


    );


  }


}