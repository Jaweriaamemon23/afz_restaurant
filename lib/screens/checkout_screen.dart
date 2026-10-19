import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  static const Color orange = Color(0xFFFF642F);
  static const Color background = Color(0xFFF7F8FA);
  static const Color dark = Color(0xFF202124);

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final streetController = TextEditingController();
  final buildingController = TextEditingController();
  final floorController = TextEditingController();
  final landmarkController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();

  bool isLoading = false;
  bool isLoadingProfile = true;

  String selectedOrderType = 'Delivery';
  String selectedPaymentMethod = 'Cash on Delivery';

  String countryCode = 'PK';
  String dialCode = '92';
  String completePhoneNumber = '';

  double get subtotal {
    double amount = 0;
    for (final item in widget.cartItems) {
      amount += getPrice(item['price']) * getQuantity(item['quantity']);
    }
    return amount;
  }

  double get deliveryFee => selectedOrderType == 'Delivery' ? 150.0 : 0.0;

  double get total => subtotal + deliveryFee;

  double getPrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return 0;

    final text = value
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

      final data = doc.data() ?? {};

      // Never overwrite text that the customer has already entered.
      if (nameController.text.trim().isEmpty) {
        nameController.text =
            data['fullName']?.toString() ?? user.displayName ?? '';
      }

      if (phoneController.text.trim().isEmpty) {
        String savedPhone = data['phone']?.toString() ?? '';

        // Support previously saved Pakistani numbers such as +92...
        if (savedPhone.startsWith('+92')) {
          savedPhone = savedPhone.substring(3);
        } else if (savedPhone.startsWith('0092')) {
          savedPhone = savedPhone.substring(4);
        } else if (savedPhone.startsWith('92') && savedPhone.length > 10) {
          savedPhone = savedPhone.substring(2);
        }

        phoneController.text = savedPhone;
        completePhoneNumber = savedPhone.isEmpty ? '' : '+$dialCode$savedPhone';
      }

      if (streetController.text.isEmpty) {
        streetController.text = data['street']?.toString() ?? '';
      }
      if (buildingController.text.isEmpty) {
        buildingController.text = data['building']?.toString() ?? '';
      }
      if (floorController.text.isEmpty) {
        floorController.text = data['floor']?.toString() ?? '';
      }
      if (landmarkController.text.isEmpty) {
        landmarkController.text = data['landmark']?.toString() ?? '';
      }
    } catch (e) {
      print('Error loading customer data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoadingProfile = false);
      }
    }
  }

  String buildFullAddress() {
    return [
      streetController.text.trim(),
      buildingController.text.trim(),
      floorController.text.trim(),
      landmarkController.text.trim(),
      areaController.text.trim(),
      cityController.text.trim(),
    ].where((part) => part.isNotEmpty).join(', ');
  }

  String? requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label.';
    }
    return null;
  }

  Future<void> placeOrder() async {
    if (isLoading) return;

    if (widget.cartItems.isEmpty) {
      showMessage('Your cart is empty.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Please enter your phone number.');
      return;
    }

    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 7 || digits.length > 15) {
      showMessage('Please enter a valid phone number.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please log in to place an order.');
      return;
    }

    if (user.email == null || user.email!.trim().isEmpty) {
      showMessage('Your account has no email address.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final orderItems = widget.cartItems.map((item) {
        return <String, dynamic>{
          'name': item['name']?.toString() ?? 'Item',
          'category': item['category']?.toString() ?? '',
          'price': getPrice(item['price']),
          'quantity': getQuantity(item['quantity']),
          'image': item['image']?.toString() ?? '',
        };
      }).toList();

      final finalSubtotal = orderItems.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item['price'] as num).toDouble() *
                (item['quantity'] as num).toInt(),
      );

      final finalDeliveryFee = selectedOrderType == 'Delivery' ? 150.0 : 0.0;

      final finalTotal = finalSubtotal + finalDeliveryFee;

      final finalName = nameController.text.trim();
      final finalPhone = completePhoneNumber.isNotEmpty
          ? completePhoneNumber
          : '+$dialCode${phoneController.text.trim()}';

      final finalAddress = selectedOrderType == 'Delivery'
          ? buildFullAddress()
          : '';

      // Preserve the existing notification workflow.
      try {
        await NotificationService.instance.saveTokenForCurrentUser();
      } catch (e) {
        print('FCM token save error: $e');
      }

      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      await orderRef.set({
        'orderId': orderRef.id,
        'userId': user.uid,
        'customerName': finalName,
        'customerEmail': user.email,
        'phone': finalPhone,
        'items': orderItems,
        'subtotal': finalSubtotal,
        'deliveryFee': finalDeliveryFee,
        'total': finalTotal,
        'orderType': selectedOrderType,
        'paymentMethod': selectedPaymentMethod,

        // Existing combined address for compatibility.
        'address': finalAddress,

        // Structured fields for admin and the future rider module.
        'street': selectedOrderType == 'Delivery'
            ? streetController.text.trim()
            : '',
        'building': selectedOrderType == 'Delivery'
            ? buildingController.text.trim()
            : '',
        'floor': selectedOrderType == 'Delivery'
            ? floorController.text.trim()
            : '',
        'landmark': selectedOrderType == 'Delivery'
            ? landmarkController.text.trim()
            : '',
        'area': selectedOrderType == 'Delivery'
            ? areaController.text.trim()
            : '',
        'city': selectedOrderType == 'Delivery'
            ? cityController.text.trim()
            : '',

        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save the latest customer details for future checkouts.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': finalName,
        'phone': finalPhone,
        if (selectedOrderType == 'Delivery') ...{
          'street': streetController.text.trim(),
          'building': buildingController.text.trim(),
          'floor': floorController.text.trim(),
          'landmark': landmarkController.text.trim(),
          'area': areaController.text.trim(),
          'city': cityController.text.trim(),
        },
      }, SetOptions(merge: true));

      widget.cartItems.clear();
      widget.onOrderPlaced();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderSuccessScreen(orderId: orderRef.id, total: finalTotal),
        ),
      );
    } catch (e) {
      print('Place order error: $e');
      if (mounted) {
        showMessage('Unable to place your order. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration fieldDecoration(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: orange, size: 21),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E5EA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E5EA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget sectionHeading(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: dark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget orderItemCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Item';
    final price = getPrice(item['price']);
    final quantity = getQuantity(item['quantity']);
    final image = item['image']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child: image.startsWith('http')
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _foodPlaceholder(),
                    )
                  : _foodPlaceholder(),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rs. ${price.toStringAsFixed(0)} each',
                  style: const TextStyle(
                    color: orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rs. ${(price * quantity).toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodPlaceholder() {
    return Container(
      color: const Color(0xFFFFF0E9),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant, color: orange, size: 30),
    );
  }

  Widget orderTypeOption({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final selected = selectedOrderType == title;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() {
          selectedOrderType = title;

          if (title != 'Delivery' &&
              selectedPaymentMethod == 'Cash on Delivery') {
            selectedPaymentMethod = 'Cash at Restaurant';
          } else if (title == 'Delivery' &&
              selectedPaymentMethod == 'Cash at Restaurant') {
            selectedPaymentMethod = 'Cash on Delivery';
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF2EC) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? orange : const Color(0xFFE2E5EA),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? orange : Colors.grey.shade600,
                size: 25,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: selected ? orange : dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentOption(String value, IconData icon) {
    final selected = selectedPaymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7F3) : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? orange : const Color(0xFFE2E5EA),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? orange : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? orange : Colors.grey,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? dark : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: FontWeight.w800,
              color: isTotal ? orange : dark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: dark),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: dark,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Almost there!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Confirm your details to place your order.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  sectionHeading(
                    'Your Order',
                    subtitle: '${widget.cartItems.length} item(s)',
                  ),
                  sectionCard(
                    child: widget.cartItems.isEmpty
                        ? const Text('Your cart is empty.')
                        : Column(
                            children: [
                              for (
                                int i = 0;
                                i < widget.cartItems.length;
                                i++
                              ) ...[
                                if (i > 0) const Divider(height: 12),
                                orderItemCard(widget.cartItems[i]),
                              ],
                            ],
                          ),
                  ),

                  const SizedBox(height: 24),
                  sectionHeading(
                    'Customer Information',
                    subtitle: 'Enter the name and phone number for this order.',
                  ),
                  sectionCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name.';
                            }
                            if (value.trim().length < 2) {
                              return 'Please enter a valid name.';
                            }
                            return null;
                          },
                          decoration: fieldDecoration(
                            'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Phone Number',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        IntlPhoneField(
                          controller: phoneController,
                          initialCountryCode: countryCode,
                          disableLengthCheck: true,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: fieldDecoration(
                            'Phone Number',
                            hint: 'Enter phone number',
                          ),
                          onCountryChanged: (country) {
                            countryCode = country.code;
                            dialCode = country.dialCode;
                            completePhoneNumber =
                                phoneController.text.trim().isEmpty
                                ? ''
                                : '+$dialCode'
                                      '${phoneController.text.trim()}';
                          },
                          onChanged: (phone) {
                            dialCode = phone.countryCode.replaceFirst('+', '');
                            completePhoneNumber = phone.completeNumber;
                          },
                        ),
                        if (isLoadingProfile)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Loading saved details...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  sectionHeading(
                    'Order Type',
                    subtitle:
                        'Choose how you would like to receive your order.',
                  ),
                  Row(
                    children: [
                      orderTypeOption(
                        title: 'Delivery',
                        description: 'To your door',
                        icon: Icons.delivery_dining,
                      ),
                      const SizedBox(width: 9),
                      orderTypeOption(
                        title: 'Pickup',
                        description: 'Collect it',
                        icon: Icons.storefront_outlined,
                      ),
                      const SizedBox(width: 9),
                      orderTypeOption(
                        title: 'Dine-in',
                        description: 'Eat here',
                        icon: Icons.restaurant_outlined,
                      ),
                    ],
                  ),

                  if (selectedOrderType == 'Delivery') ...[
                    const SizedBox(height: 24),
                    sectionHeading(
                      'Delivery Address',
                      subtitle:
                          'Provide enough detail for the rider to find you.',
                    ),
                    sectionCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: streetController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                selectedOrderType == 'Delivery'
                                ? requiredValidator(
                                    value,
                                    'your street address',
                                  )
                                : null,
                            decoration: fieldDecoration(
                              'Street Address',
                              hint: 'Street name and number',
                              icon: Icons.location_on_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: buildingController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: fieldDecoration(
                              'House / Building',
                              hint: 'House or building number',
                              icon: Icons.home_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: floorController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: fieldDecoration(
                              'Apartment / Floor',
                              hint: 'Apartment, floor, or unit (optional)',
                              icon: Icons.apartment_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: landmarkController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            decoration: fieldDecoration(
                              'Nearby Landmark',
                              hint: 'Nearby shop, mosque, or landmark',
                              icon: Icons.place_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: areaController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                selectedOrderType == 'Delivery'
                                ? requiredValidator(value, 'your area')
                                : null,
                            decoration: fieldDecoration(
                              'Area / Neighborhood',
                              hint: 'Enter your area',
                              icon: Icons.map_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: cityController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            validator: (value) =>
                                selectedOrderType == 'Delivery'
                                ? requiredValidator(value, 'your city')
                                : null,
                            decoration: fieldDecoration(
                              'City',
                              hint: 'Enter your city',
                              icon: Icons.location_city_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  sectionHeading('Payment Method'),
                  sectionCard(
                    child: Column(
                      children: [
                        paymentOption(
                          'Cash on Delivery',
                          Icons.delivery_dining,
                        ),
                        paymentOption(
                          'Cash at Restaurant',
                          Icons.storefront_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  sectionHeading('Order Summary'),
                  sectionCard(
                    child: Column(
                      children: [
                        summaryRow(
                          'Subtotal',
                          'Rs. ${subtotal.toStringAsFixed(0)}',
                        ),
                        summaryRow(
                          'Delivery Fee',
                          deliveryFee == 0
                              ? 'Free'
                              : 'Rs. ${deliveryFee.toStringAsFixed(0)}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        summaryRow(
                          'Total Amount',
                          'Rs. ${total.toStringAsFixed(0)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Place Order  •  Rs. ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Your order details will be securely saved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    final shortOrderId = orderId.length > 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Placed!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Thank you for ordering from AFZ Restaurant.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'YOUR ORDER NUMBER',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          shortOrderId,
                          style: const TextStyle(
                            color: orange,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Total Paid at Checkout',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Rs. ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Payment will be collected according to your selected payment method.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
