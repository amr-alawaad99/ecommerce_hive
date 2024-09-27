
class Product {
  final String id;
  final String userId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String dateTime;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'dateTime': dateTime,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      dateTime: map['dateTime'],
    );
  }
}
