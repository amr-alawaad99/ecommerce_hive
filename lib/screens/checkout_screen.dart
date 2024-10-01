import 'dart:math';

import 'package:ecommere_hive_javaprint/models/product_model.dart';
import 'package:ecommere_hive_javaprint/screens/bluetooth_print_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
      ui.Image image = await boundary.toImage(pixelRatio: 2);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image to the device for preview
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/receipt.png'; // Save to the same path
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
        title: const Text('Receipt Preview'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white, // Background color
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _globalKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          "شركة الشركة", // Title in Arabic
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("س-ت:1234")),
                          Text("ب-ض:123-456-789")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("رقم الفاتورة:123456")),
                          Text("Sep 2024 12:12 12")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("نوع الفاتورة: مرتجع")),
                          Text("طريقة الدفع:Credit")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("كود المندوب:12")),
                          Text("اسم المندوب:احمد محمد احمد")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("كود العميل: 323")),
                          Text("اسم العميل: محمد أحمد محمد")
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("عنوان العميل:المنصورة")),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Expanded(flex: 1, child: Text("الرقم")),
                          SizedBox(width: 10,),
                          Expanded(flex: 4, child: FittedBox(child: Text("كود الصنف # خصم %\nاسم الصنف # ضريبة %", textAlign: TextAlign.center,)),),
                          SizedBox(width: 10,),
                          Expanded(flex: 1, child: FittedBox(child: Text("خصم\nضريبة", textAlign: TextAlign.center,))),
                          SizedBox(width: 10,),
                          Expanded(flex: 1, child: FittedBox(child: Text("كمية\nوحدة", textAlign: TextAlign.center,))),
                          SizedBox(width: 10,),
                          Expanded(flex: 2, child: Text("سعر\nإجمالي", textAlign: TextAlign.center,))
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 10),
                      ...List.generate(products.length, (index) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1,child: Text((index+1).toString()),),
                              const SizedBox(width: 10,),
                              Expanded(flex: 4,child: Text("${Random().nextInt(999999999)}\n${products[index].name}", textAlign: TextAlign.center,),),
                              const SizedBox(width: 10,),

                              const Expanded(flex: 1,child: Text("0.00\n0.00", textAlign: TextAlign.center,),),

                              const SizedBox(width: 10,),
                              const Expanded(flex: 1,child: Text("1\nطرد", textAlign: TextAlign.center,),),

                              const SizedBox(width: 10,),
                              Expanded(flex: 2,child: Text("${products[index].price}\n${products[index].price}", textAlign: TextAlign.center,),)
                            ],
                          ),
                          const SizedBox(height: 10,),
                          const Divider(color: Colors.black),
                        ],
                      ),),
                      Row(
                        children: [
                          const Expanded(child: Text("إجمالي الفاتورة")),
                          Text(totalPrice.toString()),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("خصم المنتج")),
                          Text("0.00"),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("خصم اضافي")),
                          Text("0.00"),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("خصم")),
                          Text("0.00"),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Row(
                        children: [
                          Expanded(child: Text("ضريبة")),
                          Text("0.00"),
                        ],
                      ),
                      const SizedBox(height: 10,),
                      const Divider(color: Colors.black),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Expanded(child: Text("ضريبة")),
                          Text(totalPrice.toString()),
                        ],
                      ),
                  
                  
                  
                  
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () async {
          await _capturePng();
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PrintersView(),));
        },
      ),
    );
  }
}
