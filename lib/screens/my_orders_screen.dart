import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  static const Color orange = Color(0xFFFF642F);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // ============================================================
  // LOAD ONLY CURRENT USER'S ORDERS
  // ============================================================

  Future<void> loadOrders() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final List<Map<String, dynamic>> loadedOrders = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        data['documentId'] = doc.id;

        loadedOrders.add(data);
      }

      // Sort newest orders first.
      loadedOrders.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];

        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }

        return 0;
      });

      if (mounted) {
        setState(() {
          orders = loadedOrders;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load your orders.'),
            backgroundColor: orange,
          ),
        );
      }
    }
  }

  // ============================================================
  // ORDER ID
  // ============================================================

  String getShortOrderId(String orderId) {
    if (orderId.length > 8) {
      return orderId.substring(0, 8).toUpperCase();
    }

    return orderId.toUpperCase();
  }

  // ============================================================
  // DATE
  // ============================================================

  String formatDate(dynamic timestamp) {
    if (timestamp is! Timestamp) {
      return 'Just now';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$day/$month/$year • $hour:$minute $period';
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'preparing':
        return Colors.blue;

      case 'ready':
        return Colors.purple;

      case 'out for delivery':
        return Colors.indigo;

      case 'delivered':
        return Colors.green;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // NUMBER OF ITEMS
  // ============================================================

  int getItemCount(List<dynamic> items) {
    int count = 0;

    for (final item in items) {
      if (item is Map<String, dynamic>) {
        count += (item['quantity'] as num?)?.toInt() ?? 1;
      }
    }

    return count;
  }

  // ============================================================
  // ORDER CARD
  // ============================================================

  Widget orderCard(Map<String, dynamic> order) {
    final String orderId = order['orderId'] ?? order['documentId'] ?? '';

    final String status = order['status'] ?? 'Pending';

    final double total = (order['total'] as num?)?.toDouble() ?? 0;

    final double subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0;

    final double deliveryFee = (order['deliveryFee'] as num?)?.toDouble() ?? 0;

    final String orderType = order['orderType'] ?? 'Delivery';

    final String paymentMethod = order['paymentMethod'] ?? '';

    final String address = order['address'] ?? '';

    final List<dynamic> items = order['items'] is List ? order['items'] : [];

    final int itemCount = getItemCount(items);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          showOrderDetails(order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // ORDER ID + STATUS
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order ID',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${getShortOrderId(orderId)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(),

              const SizedBox(height: 10),

              // --------------------------------------------------
              // ITEMS
              // --------------------------------------------------
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: orange,
                    size: 21,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    '$itemCount ${itemCount == 1 ? 'Item' : 'Items'}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: orange,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // ORDER TYPE
              // --------------------------------------------------
              Row(
                children: [
                  Icon(
                    orderType == 'Delivery'
                        ? Icons.delivery_dining
                        : orderType == 'Pickup'
                        ? Icons.storefront_outlined
                        : Icons.restaurant_outlined,
                    size: 19,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    orderType,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // --------------------------------------------------
              // DATE
              // --------------------------------------------------
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDate(order['createdAt']),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // VIEW DETAILS
              // --------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: () {
                    showOrderDetails(order);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: orange,
                    side: const BorderSide(color: orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Order Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ORDER DETAILS
  // ============================================================

  void showOrderDetails(Map<String, dynamic> order) {
    final String orderId = order['orderId'] ?? order['documentId'] ?? '';

    final String status = order['status'] ?? 'Pending';

    final String orderType = order['orderType'] ?? 'Delivery';

    final String paymentMethod = order['paymentMethod'] ?? '';

    final String address = order['address'] ?? '';

    final double subtotal = (order['subtotal'] as num?)?.toDouble() ?? 0;

    final double deliveryFee = (order['deliveryFee'] as num?)?.toDouble() ?? 0;

    final double total = (order['total'] as num?)?.toDouble() ?? 0;

    final List<dynamic> items = order['items'] is List ? order['items'] : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F8F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // --------------------------------------------------
              // HEADER
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------------
                      // ORDER INFORMATION
                      // ------------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Order Number',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '#${getShortOrderId(orderId)}',
                              style: const TextStyle(
                                color: orange,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor(status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              formatDate(order['createdAt']),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // ITEMS
                      // ------------------------------------------------
                      const Text(
                        'Ordered Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: items.map((item) {
                            final Map<String, dynamic> itemData =
                                Map<String, dynamic>.from(item);

                            final String name = itemData['name'] ?? '';

                            final double price =
                                (itemData['price'] as num?)?.toDouble() ?? 0;

                            final int quantity =
                                (itemData['quantity'] as num?)?.toInt() ?? 1;

                            final String image = itemData['image'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      image,
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 55,
                                              height: 55,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.fastfood,
                                                color: orange,
                                              ),
                                            );
                                          },
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Qty: $quantity × Rs. ${price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Text(
                                    'Rs. ${(price * quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // ORDER INFORMATION
                      // ------------------------------------------------
                      const Text(
                        'Order Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            detailRow('Order Type', orderType),
                            detailRow('Payment', paymentMethod),

                            if (orderType == 'Delivery' && address.isNotEmpty)
                              detailRow('Address', address),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // PRICE SUMMARY
                      // ------------------------------------------------
                      const Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            summaryRow(
                              'Subtotal',
                              'Rs. ${subtotal.toStringAsFixed(0)}',
                            ),
                            const SizedBox(height: 10),
                            summaryRow(
                              'Delivery Fee',
                              deliveryFee == 0
                                  ? 'Free'
                                  : 'Rs. ${deliveryFee.toStringAsFixed(0)}',
                            ),
                            const Divider(height: 25),
                            summaryRow(
                              'Total',
                              'Rs. ${total.toStringAsFixed(0)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget summaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? orange : Colors.black87,
            fontSize: isTotal ? 19 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Please login to view your orders.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : isLoading
          ? const Center(child: CircularProgressIndicator(color: orange))
          : orders.isEmpty
          ? RefreshIndicator(
              color: orange,
              onRefresh: loadOrders,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 75,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 18),
                  Center(
                    child: Text(
                      'No Orders Yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your orders will appear here.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: orange,
              onRefresh: loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return orderCard(orders[index]);
                },
              ),
            ),
    );
  }
}
