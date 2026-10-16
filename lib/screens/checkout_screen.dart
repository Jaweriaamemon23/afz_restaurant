import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onOrderPlaced;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.onOrderPlaced,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  String customerName = '';
  String selectedOrderType = 'Delivery';
  String selectedPaymentMethod = 'Cash on Delivery';

  static const Color orange = Color(0xFFFF642F);

  // Supports both numeric prices and strings such as "Rs. 1,250".
  double getPrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return 0;

    String text = value
        .toString()
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(text) ?? 0;
  }

  int getQuantity(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 1;
  }

  double get subtotal {
    double amount = 0;

    for (final item in widget.cartItems) {
      amount += getPrice(item['price']) * getQuantity(item['quantity']);
    }

    return amount;
  }

  double get deliveryFee => selectedOrderType == 'Delivery' ? 150.0 : 0.0;

  double get total => subtotal + deliveryFee;

  @override
  void initState() {
    super.initState();
    loadCustomerData();
  }

  Future<void> loadCustomerData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          setState(() {
            customerName = data['fullName']?.toString() ?? '';
            phoneController.text = data['phone']?.toString() ?? '';
          });
        }
      } else {
        setState(() {
          customerName = user.displayName ?? '';
        });
      }
    } catch (e) {
      print('Error loading customer data: $e');
    }
  }

  Future<void> placeOrder() async {
    if (widget.cartItems.isEmpty) {
      showMessage('Your cart is empty.');
      return;
    }

    if (selectedOrderType == 'Delivery' &&
        addressController.text.trim().isEmpty) {
      showMessage('Please enter your delivery address.');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Please enter your phone number.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login to place an order.');
      return;
    }

    if (user.email == null || user.email!.trim().isEmpty) {
      showMessage('Your account has no email address.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Take a snapshot so the order details stay consistent.
      final List<Map<String, dynamic>> orderItems = widget.cartItems.map((
        item,
      ) {
        return <String, dynamic>{
          'name': item['name']?.toString() ?? 'Item',
          'category': item['category']?.toString() ?? '',
          'price': getPrice(item['price']),
          'quantity': getQuantity(item['quantity']),
          'image': item['image']?.toString() ?? '',
        };
      }).toList();

      final double finalSubtotal = orderItems.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item['price'] as num).toDouble() *
                (item['quantity'] as num).toInt(),
      );

      final double finalDeliveryFee = selectedOrderType == 'Delivery'
          ? 150.0
          : 0.0;

      final double finalTotal = finalSubtotal + finalDeliveryFee;

      final String finalName = customerName.isNotEmpty
          ? customerName
          : (user.displayName ?? 'Customer');

      final String finalAddress = selectedOrderType == 'Delivery'
          ? addressController.text.trim()
          : '';

      // Save the signed-in customer's FCM token before creating the order.
      // If token saving fails, do not block checkout.
      try {
        await NotificationService.instance.saveTokenForCurrentUser();
      } catch (e) {
        print('FCM token save error: $e');
      }

      // Save the order in Firestore. The Cloud Function will send the push
      // notifications and Gmail confirmation email when this document is created.
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      await orderRef.set({
        'orderId': orderRef.id,
        'userId': user.uid,
        'customerName': finalName,
        'customerEmail': user.email,
        'phone': phoneController.text.trim(),
        'items': orderItems,
        'subtotal': finalSubtotal,
        'deliveryFee': finalDeliveryFee,
        'total': finalTotal,
        'orderType': selectedOrderType,
        'paymentMethod': selectedPaymentMethod,
        'address': finalAddress,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear the cart only after the order has been saved.
      widget.cartItems.clear();
      widget.onOrderPlaced();

      if (!mounted) return;

      // Show the order success screen with the correct total.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OrderSuccessScreen(orderId: orderRef.id, total: finalTotal),
        ),
      );
    } catch (e) {
      print('Place order error: $e');

      if (mounted) {
        showMessage('Failed to place order. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: orange));
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget optionCard({
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    final selected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? orange : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? orange : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: orange,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Your Order'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: widget.cartItems.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final price = getPrice(item['price']);
                  final quantity = getQuantity(item['quantity']);
                  final image = item['image']?.toString() ?? '';

                  return Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          image,
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 65,
                              height: 65,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.fastfood, color: orange),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']?.toString() ?? 'Item',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Qty: $quantity',
                              style: TextStyle(color: Colors.grey.shade600),
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
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            sectionTitle('Customer Information'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: customerName,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: orange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '03001234567',
                      counterText: '',
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: orange,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            sectionTitle('Order Type'),
            optionCard(
              title: 'Delivery',
              value: 'Delivery',
              groupValue: selectedOrderType,
              icon: Icons.delivery_dining,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedOrderType = value);
              },
            ),
            optionCard(
              title: 'Pickup',
              value: 'Pickup',
              groupValue: selectedOrderType,
              icon: Icons.storefront_outlined,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedOrderType = value);
              },
            ),
            optionCard(
              title: 'Dine-in',
              value: 'Dine-in',
              groupValue: selectedOrderType,
              icon: Icons.restaurant_outlined,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedOrderType = value);
              },
            ),

            if (selectedOrderType == 'Delivery') ...[
              const SizedBox(height: 14),
              sectionTitle('Delivery Address'),
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your complete delivery address',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 45),
                    child: Icon(Icons.location_on_outlined, color: orange),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            sectionTitle('Payment Method'),
            optionCard(
              title: 'Cash on Delivery',
              value: 'Cash on Delivery',
              groupValue: selectedPaymentMethod,
              icon: Icons.money_outlined,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedPaymentMethod = value);
              },
            ),
            optionCard(
              title: 'Cash at Restaurant',
              value: 'Cash at Restaurant',
              groupValue: selectedPaymentMethod,
              icon: Icons.payments_outlined,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedPaymentMethod = value);
              },
            ),

            const SizedBox(height: 24),
            sectionTitle('Order Summary'),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  summaryRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(0)}'),
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

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
}

// ============================================================
// ORDER SUCCESS SCREEN
// ============================================================

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final double total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  static const Color orange = Color(0xFFFF642F);

  @override
  Widget build(BuildContext context) {
    final String shortOrderId = orderId.length > 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: const BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 55),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Order Placed!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Order ID',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        shortOrderId,
                        style: const TextStyle(
                          color: orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Total: Rs. ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
