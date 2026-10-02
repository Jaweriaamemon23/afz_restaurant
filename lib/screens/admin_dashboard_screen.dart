import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
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
            margin: const EdgeInsets.only(right: 18),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_outline, color: Color(0xFFFF642F)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant status
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A45), Color(0xFFFF5722)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AFZ Restaurant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your restaurant is currently open',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'OPEN',
                      style: TextStyle(
                        color: Color(0xFFFF642F),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Today's Overview",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
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
                  title: 'Pending',
                  value: '18',
                  icon: Icons.pending_actions_rounded,
                ),
                _StatCard(
                  title: 'Deliveries',
                  value: '24',
                  icon: Icons.delivery_dining_rounded,
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 15),

            Row(
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

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFFF642F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            _OrderCard(
              order: '#AFZ-1024',
              customer: 'Ali Ahmed',
              amount: 'Rs. 2,450',
              status: 'Preparing',
            ),

            _OrderCard(
              order: '#AFZ-1023',
              customer: 'Sara Khan',
              amount: 'Rs. 1,850',
              status: 'Ready',
            ),

            _OrderCard(
              order: '#AFZ-1022',
              customer: 'Ahmed Raza',
              amount: 'Rs. 3,200',
              status: 'On the way',
            ),
          ],
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.all(15),
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
          Icon(icon, color: const Color(0xFFFF642F), size: 25),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFF642F), size: 25),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String order;
  final String customer;
  final String amount;
  final String status;

  const _OrderCard({
    required this.order,
    required this.customer,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFFFF642F),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
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
              const SizedBox(height: 4),
              Text(
                status,
                style: const TextStyle(
                  color: Color(0xFFFF642F),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
