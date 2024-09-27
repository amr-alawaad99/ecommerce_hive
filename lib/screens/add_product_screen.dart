import 'package:ecommerce_hive/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit/product_cubit.dart';
import '../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  double _price = 0;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) => _name = value,
                validator: (value) => value!.isEmpty ? 'Please enter product name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => _description = value,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _price = double.tryParse(value) ?? 0,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => _imageUrl = value,
                validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final product = Product(
                      id: '', // ID will be generated later
                      userId: stringBox!.get("uid")!,
                      name: _name,
                      description: _description,
                      price: _price,
                      imageUrl: _imageUrl,
                      dateTime: DateTime.now().toString(),
                    );
                    context.read<ProductCubit>().onAddingProduct(product);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
