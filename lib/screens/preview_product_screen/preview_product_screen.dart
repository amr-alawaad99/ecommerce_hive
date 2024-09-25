// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../cubit/product_cubit/product_cubit.dart';
//
//
// class PreviewProductScreen extends StatelessWidget {
//   final String name;
//   final String description;
//   final double price;
//   final List<XFile> images;
//
//   PreviewProductScreen({
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.images,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Preview Product')),
//       body: Column(
//         children: [
//           Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           Text(description),
//           Text('Price: \$${price.toStringAsFixed(2)}'),
//           SizedBox(height: 10),
//           Expanded(
//             child: ListView.builder(
//               itemCount: images.length,
//               itemBuilder: (context, index) {
//                 return Image.file(File(images[index].path), fit: BoxFit.cover);
//               },
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Call the cubit to add the product
//               context.read<ProductCubit>().addProduct(name, description, price, images.map((e) => e.path).toList());
//               Navigator.popUntil(context, (route) => route.isFirst); // Go back to home screen
//             },
//             child: Text('Add Product'),
//           ),
//         ],
//       ),
//     );
//   }
// }
