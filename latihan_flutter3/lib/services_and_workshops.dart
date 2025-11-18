import 'package:flutter/material.dart';

// 4) TOP SERVICES + BEST BOOKINGS + BANNER + BOOKING CARDS + RECOMMENDED WORKSHOPS
class ServicesAndWorkshopsSection extends StatelessWidget {
  const ServicesAndWorkshopsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== Top Services =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 22, 147),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Top Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: List.generate(3, (i) {
                  final coverUrls = [
                    'https://picsum.photos/900/600/?blur=9',
                    'https://picsum.photos/id/33/1350/900',
                    'https://picsum.photos/1200/800'
                  ];
                  final coverUrl = coverUrls[i % coverUrls.length];
                  final avatarUrl = 'https://i.pravatar.cc/100?img=${i + 13}';

                  return Padding(
                    padding: EdgeInsets.only(bottom: i == 2 ? 0 : 20),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final totalW = c.maxWidth;
                        final imageW = totalW * 0.56;
                        final cardW = totalW * 0.56;
                        const double h = 190;
                        const double cardTop = 22;
                        const double radius = 22;

                        return SizedBox(
                          height: h + 10,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: imageW,
                                  height: h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(radius),
                                    image: DecorationImage(
                                      image: NetworkImage(coverUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: cardTop,
                                right: 0,
                                child: Container(
                                  width: cardW,
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x1A000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipOval(
                                            child: Image.network(
                                              avatarUrl,
                                              width: 36,
                                              height: 36,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Mister brezek',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  'Beautician',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF7B61FF),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Doloribus saepe aut necessitat qui non qui.',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8B8B8B),
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1EDFF),
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.star, size: 16, color: Color(0xFF7B61FF)),
                                                SizedBox(width: 6),
                                                Text('4.9', style: TextStyle(fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            height: 38,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color.fromARGB(255, 253, 139, 255),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                              onPressed: () {},
                                              child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // ===== Best Bookings (header) =====
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 22, 147),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Best Bookings',
                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ===== Deal Of The Day Banner =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final double imageW = w * 0.38;
              final double clampedImageW = imageW.clamp(120, 170).toDouble();

              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7FB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      right: clampedImageW + 8,
                      top: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text('Deal Of The Day',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Row(
                            children: const [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Flat 60% OFF',
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.auto_awesome, size: 18, color: Color(0xFF7B61FF)),
                            ],
                          ),
                          const SizedBox(height: 1),
                          const Expanded(
                            child: Text(
                              'alter ego gogogogoggogoggogoggo  .',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B), height: 1.3, ),
                            ),
                          ),

                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 7,
                            children: [
                              _timeBoxInline('06'),
                              const Text(':', style: TextStyle(fontWeight: FontWeight.w800)),
                              _timeBoxInline('34'),
                              const Text(':', style: TextStyle(fontWeight: FontWeight.w800)),
                              _timeBoxInline('15'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 20,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                elevation: 0,
                              ),
                              onPressed: () {},
                              child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: clampedImageW,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.asset(
                          'lib/images/jaket_hijau.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // ===== Booking cards =====
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ITEM 1
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/seed/picsum/536/354',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          'https://i.pravatar.cc/100?img=21',
                          width: 44, height: 44, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'brezek',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Beautician',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7B61FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EDFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Color(0xFF7B61FF)),
                            SizedBox(width: 6),
                            Text('4.9', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Occaecati aut nam beatae quo non deserunt consequatur.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B), height: 1.4),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ITEM 2
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/id/870/536/354?grayscale&blur=2',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.network(
                          'https://i.pravatar.cc/100?img=22',
                          width: 44, height: 44, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'dewa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Beautician',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7B61FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EDFF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 16, color: Color(0xFF7B61FF)),
                            SizedBox(width: 6),
                            Text('4.9', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Occaecati aut nam beatae quo non deserunt consequatur.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B6B6B), height: 1.4),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ===== Recommended Workshops =====
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.white, blurRadius: 15, offset: Offset(0, 6)),
              ],
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFC2D7F2), Colors.white, Colors.white],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recommended Workshops',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6F7FB), Color(0xFFEFF3FF)],
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.52,
                  ),
                  itemBuilder: (context, i) {
                    final randomImage = 'https://picsum.photos/seed/${i + 200}/400/300';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                randomImage,
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (c, child, p) {
                                  if (p == null) return child;
                                  return const SizedBox(
                                    height: 130,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Container(
                                  height: 130,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9EEF8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EDFF),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 16, color: Color(0xFF7B61FF)),
                                    SizedBox(width: 6),
                                    Text('4.9', style: TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'rekyl',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Beautician',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7B61FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Expanded(
                          child: Text(
                            'Occaecati aut nam beatae quo non deserunt consequatur.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B), height: 1.3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 253, 139, 255),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: const Text('Book Workshop', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // disalin persis agar UI identik
  static Widget _timeBoxInline(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
  );
}
