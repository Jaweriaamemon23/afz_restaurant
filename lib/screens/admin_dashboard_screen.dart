import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color primary = Color(0xFFFF642F);
  static const Color background = Color(0xFFF7F7F8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 24,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good afternoon 👋',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 3),
            Text(
              'Restaurant Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202020),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 24),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline, color: primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 28 : 18),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HERO
                _buildHero(isDesktop),

                const SizedBox(height: 28),

                const Text(
                  "Today's Overview",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 16),

                // STAT CARDS
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1000
                        ? 4
                        : constraints.maxWidth >= 600
                        ? 2
                        : 2;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: constraints.maxWidth >= 1000
                          ? 1.75
                          : 1.45,
                      children: const [
                        _StatCard(
                          title: "Today's Sales",
                          value: 'Rs. 48,500',
                          icon: Icons.payments_outlined,
                        ),
                        _StatCard(
                          title: 'Total Orders',
                          value: '126',
                          icon: Icons.receipt_long_outlined,
                        ),
                        _StatCard(
                          title: 'Pending Orders',
                          value: '18',
                          icon: Icons.pending_actions_rounded,
                        ),
                        _StatCard(
                          title: 'Deliveries',
                          value: '24',
                          icon: Icons.delivery_dining_rounded,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                // GRAPHS
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 3, child: _OrdersChart()),
                      SizedBox(width: 18),
                      Expanded(flex: 2, child: _SalesSummary()),
                    ],
                  )
                else
                  const Column(
                    children: [
                      _OrdersChart(),
                      SizedBox(height: 18),
                      _SalesSummary(),
                    ],
                  ),

                const SizedBox(height: 30),

                // QUICK ACTIONS
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ActionButton(
                      icon: Icons.add_circle_outline,
                      title: 'Add Item',
                      onTap: () {},
                    ),
                    _ActionButton(
                      icon: Icons.receipt_long_outlined,
                      title: 'Orders',
                      onTap: () {},
                    ),
                    _ActionButton(
                      icon: Icons.menu_book_outlined,
                      title: 'Menu',
                      onTap: () {},
                    ),
                    _ActionButton(
                      icon: Icons.analytics_outlined,
                      title: 'Reports',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // POPULAR ITEMS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Menu Items',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View Menu',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1000
                        ? 4
                        : constraints.maxWidth >= 600
                        ? 2
                        : 2;

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: constraints.maxWidth >= 1000
                          ? 0.95
                          : 0.82,
                      children: const [
                        _FoodCard(
                          image:
                              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
                          name: 'Classic Burger',
                          price: 'Rs. 850',
                          orders: '42 orders',
                        ),
                        _FoodCard(
                          image:
                              'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=800',
                          name: 'Chicken Pasta',
                          price: 'Rs. 950',
                          orders: '36 orders',
                        ),
                        _FoodCard(
                          image:
                              'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
                          name: 'Chicken Pizza',
                          price: 'Rs. 1,200',
                          orders: '31 orders',
                        ),
                        _FoodCard(
                          image:
                              'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
                          name: 'Chicken Samosa',
                          price: 'Rs. 450',
                          orders: '28 orders',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // RECENT ORDERS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const _OrderCard(
                  order: '#AFZ-1024',
                  customer: 'Ali Ahmed',
                  amount: 'Rs. 2,450',
                  status: 'Preparing',
                  image:
                      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
                ),

                const _OrderCard(
                  order: '#AFZ-1023',
                  customer: 'Sara Khan',
                  amount: 'Rs. 1,850',
                  status: 'Ready',
                  image:
                      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
                ),

                const _OrderCard(
                  order: '#AFZ-1022',
                  customer: 'Ahmed Raza',
                  amount: 'Rs. 3,200',
                  status: 'On the way',
                  image:
                      'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=400',
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(bool isDesktop) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: isDesktop ? 230 : 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=1600',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: primary,
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 70,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.78),
                    Colors.black.withOpacity(0.20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'AFZ Restaurant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your restaurant, orders and menu',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 9, color: Colors.green),
                              SizedBox(width: 7),
                              Text(
                                'OPEN NOW',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Colors.white,
                        size: 55,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// STAT CARD
// ------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _AdminDashboardColors.primary, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AdminDashboardColors {
  static const Color primary = Color(0xFFFF642F);
}

// ------------------------------------------------------------
// TODAY'S ORDERS GRAPH
// ------------------------------------------------------------

class _OrdersChart extends StatelessWidget {
  const _OrdersChart();

  final List<double> orderData = const [
    5,
    8,
    6,
    12,
    15,
    11,
    18,
    22,
    19,
    26,
    31,
    28,
  ];

  final List<String> times = const [
    '9 AM',
    '10',
    '11',
    '12',
    '1 PM',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Orders received throughout the day',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '126 Orders',
                  style: TextStyle(
                    color: Color(0xFFFF642F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: CustomPaint(
              painter: _OrdersGraphPainter(data: orderData, labels: times),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersGraphPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _OrdersGraphPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF642F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFFF642F).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    const double left = 10;
    const double right = 10;
    const double top = 15;
    const double bottom = 30;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      final y = top + chartHeight - (chartHeight * i / 4);

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    final maxValue = 35.0;

    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = left + (chartWidth * i / (data.length - 1));
      final y = top + chartHeight - ((data[i] / maxValue) * chartHeight);

      points.add(Offset(x, y));
    }

    // Filled area
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, top + chartHeight);

    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }

    fillPath.lineTo(points.last.dx, top + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(linePath, paint);

    // Points
    final pointPaint = Paint()
      ..color = const Color(0xFFFF642F)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Labels
    for (int i = 0; i < labels.length; i++) {
      final x = left + (chartWidth * i / (labels.length - 1));

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Colors.grey, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ------------------------------------------------------------
// SALES SUMMARY
// ------------------------------------------------------------

class _SalesSummary extends StatelessWidget {
  const _SalesSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Sales",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Sales breakdown',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF642F), width: 18),
                ),
                child: const Center(
                  child: Text(
                    '48.5K',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 22),
              const Expanded(
                child: Column(
                  children: [
                    _SalesRow(title: 'Delivery', value: 'Rs. 28,500'),
                    SizedBox(height: 15),
                    _SalesRow(title: 'Pickup', value: 'Rs. 12,000'),
                    SizedBox(height: 15),
                    _SalesRow(title: 'Dine-in', value: 'Rs. 8,000'),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sales are higher than yesterday',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesRow extends StatelessWidget {
  final String title;
  final String value;

  const _SalesRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// QUICK ACTION
// ------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFFF642F), size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// FOOD CARD
// ------------------------------------------------------------

class _FoodCard extends StatelessWidget {
  final String image;
  final String name;
  final String price;
  final String orders;

  const _FoodCard({
    required this.image,
    required this.name,
    required this.price,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFEEE8),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Color(0xFFFF642F),
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFFFF642F),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      orders,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// ORDER CARD
// ------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  final String order;
  final String customer;
  final String amount;
  final String status;
  final String image;

  const _OrderCard({
    required this.order,
    required this.customer,
    required this.amount,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              image,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 58,
                  height: 58,
                  color: const Color(0xFFFFEEE8),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFFF642F),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  customer,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEE8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFFFF642F),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
