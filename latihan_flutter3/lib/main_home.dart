import 'package:flutter/material.dart';
import 'search_bar.dart';
import 'banner.dart';
import 'top_rated.dart';
import 'services_and_workshops.dart';
import 'cart.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Ezek-Commerce", style: TextStyle(color: Colors.black)),
        leading: IconButton(
          onPressed: () => print("MENU DI TEKAN"),
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: Image.asset(
              'lib/icons/Frame 6.png',
              width: 40,
              height: 44,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
        children: const [
          SearchBarAndFilter(),
          SizedBox(height: 16),
          PromoBanner(),
          SizedBox(height: 21),
          TopRatedFreelancesSection(),
          ServicesAndWorkshopsSection(),
        ],
      ),
    );
  }
}
