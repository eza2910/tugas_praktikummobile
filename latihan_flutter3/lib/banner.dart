import 'package:flutter/material.dart';



// 2) PROMO BANNER
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.blue,

          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(0, 6)),
          ],

          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFC2D7F2), Colors.white, Colors.white],
            stops: [0.0, 0.35, 1.0],
          ),
        ),

        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color.fromARGB(255, 253, 139, 255),
                    ],
                  ),
                ),
              ),
            ),


            Positioned(
              left: 16,
              top: 16,
              right: 150,
              child: Text(
                'Today Deal',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.0
                    ..color = const Color.fromARGB(255, 243, 22, 147), // warna outline
                ),
              ),
            ),
            const SizedBox(height: 10,),
            const Positioned(
                top: 50,
                right: 150,
                left: 16,
                child: Text("50 % OFF",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,


                  ),

                ),

            ),
           const SizedBox(height: 10),
            Positioned(
              left: 20,
             right: 150,
             top: 100,
              child: Text(
                "AYO BELI SEKARANG\n"
                    "Sebelum Kehabisan\n"
                    "Nanti nangis ",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight : FontWeight.w300
                ),
              ),
           ),
            const SizedBox(height:10),
            Positioned(
              right: 70,
              top: 0,
              bottom: 0,
              width: 140,

              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 194,
                    width:  194,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      gradient: LinearGradient(
                        begin: Alignment.center,

                        colors: [
                          const Color.fromARGB(255, 253, 139, 255),
                          const Color.fromARGB(255, 253, 139, 255),
                        ],
                      ),
                    ),
                  ),
              ),
            ),
            Positioned(
              right: 70,
              top: 0,
              bottom: 0,
              width: 140,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'lib/images/image 4.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(25)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Shop now',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right_alt,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

