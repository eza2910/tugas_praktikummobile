import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CartScreen(),
    );
  }
}

class CartItem {
  final String title;
  final String brand;
  final String image;
  final double price;
  int quantity;

  CartItem({
    required this.title,
    required this.brand,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = [
    CartItem(
      title: "Watch",
      brand: "Rolex",
      image: "lib/image/watch.jpg",
      price: 40,
      quantity: 2,
    ),
    CartItem(
      title: "Airpods",
      brand: "Apple",
      image: "lib/image/airpods.jpg",
      price: 333,
      quantity: 2,
    ),
    CartItem(
      title: "Hoodie",
      brand: "Puma",
      image: "lib/image/puma.jpg",
      price: 50,
      quantity: 2,
    )
  ];

  void increaseQty(int index) {
    setState(() => cartItems[index].quantity++);
  }

  void decreaseQty(int index) {
    if (cartItems[index].quantity > 1) {
      setState(() => cartItems[index].quantity--);
    }
  }

  void removeItem(int index) {
    setState(() => cartItems.removeAt(index));
  }

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get discount => 4;
  double get delivery => 2;
  double get total => subtotal - discount + delivery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Cart", style: TextStyle(color: Colors.black)),
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, color: Colors.black),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(item.image, width: 90, height: 90, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(item.brand, style: TextStyle(color: Colors.grey.shade500)),
                                Text("\$${item.price}", style: const TextStyle(fontSize: 16, color: Colors.blue)),
                              ]),
                        ),
                        Row(
                          children: [
                            button(Icons.remove, () => decreaseQty(index)),
                            SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(item.quantity.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            button(Icons.add, () => increaseQty(index)),
                          ],
                        ),
                        IconButton(
                          onPressed: () => removeItem(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ORDER SUMMARY
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              summaryText("Items", "${cartItems.length}"),
              summaryText("Subtotal", "\$${subtotal.toStringAsFixed(0)}"),
              summaryText("Discount", "\$${discount.toStringAsFixed(0)}"),
              summaryText("Delivery Charges", "\$${delivery.toStringAsFixed(0)}"),
              const Divider(),
              summaryText("Total", "\$${total.toStringAsFixed(0)}", bold: true),
            ]),
          ),

          // CHECKOUT BUTTON
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E55FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {},
              child: const Text("Check Out", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget button(IconData icon, Function onPressed) {
    return InkWell(
      onTap: () => onPressed(),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEDEBFD)),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget summaryText(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
