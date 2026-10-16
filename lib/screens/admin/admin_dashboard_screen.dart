import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../kitchen_display_screen.dart';
import 'add_menu_item_screen.dart';
import 'admin_menu_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color primary = Color(0xFFFF642F);
  static const Color background = Color(0xFFF7F7F8);

  CollectionReference<Map<String, dynamic>> get _orders =>
      FirebaseFirestore.instance.collection('orders');

  CollectionReference<Map<String, dynamic>> get _menuItems =>
      FirebaseFirestore.instance.collection('menuItems');

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

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
              'Restaurant Management',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 3),
            Text(
              'AFZ Restaurant Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF202020),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.restaurant, color: primary),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _orders.snapshots(),
        builder: (context, orderSnapshot) {
          final orders = orderSnapshot.data?.docs ?? [];
          final now = DateTime.now();

          final todaysOrders = orders.where((doc) {
            final value = doc.data()['createdAt'];
            if (value is! Timestamp) return false;

            final date = value.toDate();
            return date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
          }).toList();

          final todaysSales = todaysOrders.fold<double>(
            0,
            (sum, doc) => sum + _number(doc.data()['total']),
          );

          final pendingOrders = orders.where((doc) {
            final status = (doc.data()['status'] ?? '')
                .toString()
                .toLowerCase();
            return status == 'pending';
          }).length;

          final activeDeliveries = orders.where((doc) {
            final status = (doc.data()['status'] ?? '')
                .toString()
                .toLowerCase();
            return status == 'on the way' ||
                status == 'out for delivery' ||
                status == 'out_for_delivery';
          }).length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 28 : 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(isDesktop),

                    const SizedBox(height: 28),

                    const Text(
                      "Today's Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 1000 ? 4 : 2;

                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: constraints.maxWidth >= 1000
                              ? 1.75
                              : 1.45,
                          children: [
                            _StatCard(
                              title: "Today's Sales",
                              value: _money(todaysSales),
                              icon: Icons.payments_outlined,
                            ),
                            _StatCard(
                              title: "Today's Orders",
                              value: orderSnapshot.hasError
                                  ? 'Error'
                                  : '${todaysOrders.length}',
                              icon: Icons.receipt_long_outlined,
                            ),
                            _StatCard(
                              title: 'Pending Orders',
                              value: orderSnapshot.hasError
                                  ? 'Error'
                                  : '$pendingOrders',
                              icon: Icons.pending_actions_rounded,
                            ),
                            _StatCard(
                              title: 'Active Deliveries',
                              value: orderSnapshot.hasError
                                  ? 'Error'
                                  : '$activeDeliveries',
                              icon: Icons.delivery_dining_rounded,
                            ),
                          ],
                        );
                      },
                    ),

                    if (orderSnapshot.hasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Unable to load order statistics. Check Firestore '
                          'permissions and your orders collection.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 30),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ActionButton(
                          icon: Icons.receipt_long_outlined,
                          title: 'Kitchen Orders',
                          onTap: () => _openScreen(
                            context,
                            const KitchenDisplayScreen(),
                          ),
                        ),
                        _ActionButton(
                          icon: Icons.add_circle_outline,
                          title: 'Add Item',
                          onTap: () =>
                              _openScreen(context, const AddMenuItemScreen()),
                        ),
                        _ActionButton(
                          icon: Icons.menu_book_outlined,
                          title: 'Menu',
                          onTap: () =>
                              _openScreen(context, const AdminMenuScreen()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Menu Inventory',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              _openScreen(context, const AdminMenuScreen()),
                          child: const Text(
                            'Manage Menu',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _menuItems.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _InfoCard(
                            child: const Text(
                              'Unable to load menu inventory. Check your '
                              'Firestore collection and permissions.',
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const _InfoCard(
                            child: Center(
                              child: CircularProgressIndicator(color: primary),
                            ),
                          );
                        }

                        final items = snapshot.data?.docs ?? [];
                        final activeItems = items.where((doc) {
                          final data = doc.data();
                          return data['isAvailable'] != false &&
                              data['isActive'] != false;
                        }).length;

                        return _InfoCard(
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEEE8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: primary,
                                  size: 27,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${items.length} menu items',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '$activeItems available in inventory',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

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
                        Text(
                          '${orders.length} total',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (orderSnapshot.hasError)
                      const _InfoCard(
                        child: Text('Could not load recent orders.'),
                      )
                    else if (orderSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !orderSnapshot.hasData)
                      const _InfoCard(
                        child: Center(
                          child: CircularProgressIndicator(color: primary),
                        ),
                      )
                    else if (orders.isEmpty)
                      const _InfoCard(
                        child: Text(
                          'No orders have been placed yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ..._recentOrders(orders),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _recentOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    final sorted = [...orders];

    sorted.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      final aDate = aTime is Timestamp
          ? aTime.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = bTime is Timestamp
          ? bTime.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return sorted.take(5).map((doc) {
      final data = doc.data();

      final orderId = (data['orderId'] ?? doc.id).toString();
      final customer = (data['customerName'] ?? 'Customer').toString();
      final amount = _money(_number(data['total']));
      final status = (data['status'] ?? 'Pending').toString();

      final items = data['items'];
      String? image;

      if (items is List && items.isNotEmpty && items.first is Map) {
        final firstItem = Map<String, dynamic>.from(items.first as Map);
        image = (firstItem['image'] ?? firstItem['imageUrl'])?.toString();
      }

      return _OrderCard(
        order: orderId,
        customer: customer,
        amount: amount,
        status: status,
        image: image,
      );
    }).toList();
  }

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _money(double value) {
    return 'Rs. ${value.toStringAsFixed(0)}';
  }

  Widget _buildHero(bool isDesktop) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: isDesktop ? 220 : 190,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=1600',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: primary,
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 70,
                ),
              ),
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
              padding: const EdgeInsets.all(26),
              child: Align(
                alignment: Alignment.centerLeft,
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
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
                            'AFZ RESTAURANT',
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
            child: Icon(icon, color: AdminDashboardScreen.primary, size: 22),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
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
    return SizedBox(
      width: 155,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AdminDashboardScreen.primary,
                    size: 21,
                  ),
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
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String order;
  final String customer;
  final String amount;
  final String status;
  final String? image;

  const _OrderCard({
    required this.order,
    required this.customer,
    required this.amount,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();

    final statusColor =
        normalizedStatus == 'delivered' || normalizedStatus == 'ready'
        ? Colors.green
        : normalizedStatus == 'cancelled'
        ? Colors.red
        : AdminDashboardScreen.primary;

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
            child: image != null && image!.isNotEmpty
                ? Image.network(
                    image!,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
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

  Widget _imageFallback() {
    return Container(
      width: 58,
      height: 58,
      color: const Color(0xFFFFEEE8),
      child: const Icon(
        Icons.restaurant_menu,
        color: AdminDashboardScreen.primary,
      ),
    );
  }
}
