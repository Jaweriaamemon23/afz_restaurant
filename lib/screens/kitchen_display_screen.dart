import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KitchenDisplayScreen extends StatelessWidget {
  const KitchenDisplayScreen({super.key});

  static const Color orange = Color(0xFFFF642F);
  static const Color background = Color(0xFFF7F7F8);

  Future<void> updateStatus(
    BuildContext context,
    String orderDocId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderDocId)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order updated to $status')));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kitchen Display',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              'Manage incoming restaurant orders',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load orders. Check Firestore permissions '
                  'and the createdAt field.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs =
              snapshot.data?.docs ??
              <QueryDocumentSnapshot<Map<String, dynamic>>>[];

          final activeOrders = docs.where((doc) {
            final status = (doc.data()['status'] ?? 'Pending')
                .toString()
                .toLowerCase();

            return const [
              'pending',
              'accepted',
              'preparing',
              'ready',
            ].contains(status);
          }).toList();

          if (activeOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: 65, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    'All caught up!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('New customer orders will appear here.'),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1050
                  ? 3
                  : constraints.maxWidth >= 650
                  ? 2
                  : 1;

              return GridView.builder(
                padding: const EdgeInsets.all(18),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 390,
                ),
                itemCount: activeOrders.length,
                itemBuilder: (context, index) {
                  final doc = activeOrders[index];

                  return _KitchenOrderCard(
                    data: doc.data(),
                    onUpdate: (String status) {
                      updateStatus(context, doc.id, status);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final Map<String, dynamic> data;

  // Updated callback type to avoid the ValueChanged error.
  final void Function(String) onUpdate;

  const _KitchenOrderCard({required this.data, required this.onUpdate});

  static const Color orange = Color(0xFFFF642F);

  @override
  Widget build(BuildContext context) {
    final orderId = (data['orderId'] ?? 'Unknown').toString();
    final customer = (data['customerName'] ?? 'Customer').toString();
    final status = (data['status'] ?? 'Pending').toString();
    final orderType = (data['orderType'] ?? 'Order').toString();

    final items = data['items'] is List
        ? List<dynamic>.from(data['items'] as List)
        : <dynamic>[];

    final normalizedStatus = status.toLowerCase();

    final Color statusColor = normalizedStatus == 'ready'
        ? Colors.green
        : normalizedStatus == 'preparing'
        ? Colors.blue
        : orange;

    final String nextStatus;
    final String buttonText;

    if (normalizedStatus == 'pending' || normalizedStatus == 'accepted') {
      nextStatus = 'Preparing';
      buttonText = 'Start Preparing';
    } else {
      nextStatus = 'Ready';
      buttonText = 'Mark Ready';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ORDER #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    customer,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  orderType,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ORDER ITEMS',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No item details available'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index] is Map
                          ? Map<String, dynamic>.from(items[index] as Map)
                          : <String, dynamic>{};

                      final name = (item['name'] ?? 'Item').toString();
                      final quantity = item['quantity'] ?? 1;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEE8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '×$quantity',
                                style: const TextStyle(
                                  color: orange,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if ((data['specialInstructions'] ?? '').toString().trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4D8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Instructions: ${data['specialInstructions']}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: normalizedStatus == 'ready'
                  ? const OutlinedButton(
                      onPressed: null,
                      child: Text('Order Ready'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => onUpdate(nextStatus),
                      icon: Icon(
                        nextStatus == 'Ready'
                            ? Icons.check_circle_outline
                            : Icons.soup_kitchen_outlined,
                      ),
                      label: Text(buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
