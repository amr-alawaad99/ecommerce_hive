import 'package:ecommerce_hive/models/product_model.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CheckoutScreen extends StatelessWidget {
  final List<Product> products;
  final double totalPrice;
  CheckoutScreen({super.key, required this.products, required this.totalPrice});

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image to the device for preview
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/receipt.png';
      File imgFile = File(imagePath);
      await imgFile.writeAsBytes(pngBytes);
      print('Image saved to: $imagePath');
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: _capturePng, // Capture the widget as an image
          ),
        ],
      ),
      body: Container(
        width: 574, // Widget width based on printer size (in pixels)
        padding: const EdgeInsets.all(16),
        color: Colors.white, // Background color
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: RepaintBoundary(
              key: _globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(),
                  const Text(
                    "فاتورة المشتريات", // Title in Arabic
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(products.length, (index) => Column(
                    children: [
                      Text("عدد 1 من المنتج: ${products[index].name}"),
                      const SizedBox(height: 10,),
                    ],
                  ),),
                  const Text("---------------------"),
                  const SizedBox(height: 10,),
                  Text("إجمالي السعر: ${totalPrice.toString()}"),
                  const SizedBox(height: 10,),
                  const Text("الخصم: 0"),
                  const Text("---------------------"),
                  const SizedBox(height: 10,),
                  Text("الصافي: إجمالي السعر: ${totalPrice.toString()}")

                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () {

        },
      ),
    );
  }
}
