import 'package:ecommere_hive_javaprint/cubit/product_cubit/product_cubit.dart';
import 'package:ecommere_hive_javaprint/shared/constants.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_button.dart';
import 'package:ecommere_hive_javaprint/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';

class EditProduct extends StatelessWidget {
  final Product product;
  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController price;
  final TextEditingController imageUrl;
  EditProduct({super.key, required this.product})
      : name = TextEditingController(text: product.name),
        description = TextEditingController(text: product.description),
        price = TextEditingController(text: product.price.toString()),
        imageUrl = TextEditingController(text: product.imageUrl);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              CustomInputField(
                hintText: "Product Name",
                controller: name,
                labelText: "Name",
              ),
              const SizedBox(height: 15,),
              CustomInputField(
                hintText: "Product Description",
                controller: description,
                labelText: "Description",
              ),
              const SizedBox(height: 15,),
              CustomInputField(
                hintText: "Product Price",
                controller: price,
                keyboardType: TextInputType.number,
                labelText: "Price",
              ),
              const SizedBox(height: 15,),
              CustomInputField(
                hintText: "Product Image URL",
                controller: imageUrl,
                labelText: "Image URL",
              ),
              const SizedBox(height: 25,),
              CustomButton(
                innerText: "Edit Product",
                color: Colors.grey,
                onPressed: () async {
                  Product updatedProduct = Product(
                    id: product.id,
                    userId: product.userId,
                    name: name.text,
                    description: description.text,
                    price: double.parse(price.text),
                    imageUrl: imageUrl.text,
                    dateTime: product.dateTime,
                  );
                  await context.read<ProductCubit>().onUpdateProduct(updatedProduct);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 25,),
              CustomButton(
                innerText: "Delete Product",
                color: Colors.redAccent,
                onPressed: () async {
                  await context.read<ProductCubit>().onDeleteProduct(product.id);
                  myProducts!.delete(product.id);
                  Navigator.pop(context);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
