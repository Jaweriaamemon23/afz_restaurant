import 'package:flutter/material.dart';
import '../login_screen.dart';
import 'customer_menu_screen.dart';
import 'customer_favorites_screen.dart';
import 'customer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final bool isGuest;

  const CustomerHomeScreen({super.key, this.isGuest = false});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

// ============================================================
// AFZ AI CHAT
// ============================================================

class _AFZAIChat extends StatefulWidget {
  const _AFZAIChat();

  @override
  State<_AFZAIChat> createState() => _AFZAIChatState();
}

class _AFZAIChatState extends State<_AFZAIChat> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      'isAI': true,
      'message':
          'Hi! 👋 I’m AFZ AI Assistant.\n\n'
          'I can help you explore the menu, choose food, understand '
          'your order, and guide you around the AFZ app.\n\n'
          'What would you like help with?',
    },
  ];

  void sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({'isAI': false, 'message': text});
    });

    messageController.clear();

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final response = getAIResponse(text);

      setState(() {
        messages.add({'isAI': true, 'message': response});
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getAIResponse(String message) {
    final text = message.toLowerCase();

    if (text.contains('menu') ||
        text.contains('food') ||
        text.contains('eat')) {
      return 'You can explore our Menu to find burgers, pizza, biryani, BBQ, drinks and desserts. 🍔🍕\n\n'
          'Would you like me to suggest something?';
    }

    if (text.contains('burger')) {
      return 'If you love burgers, try our Classic Beef Burger. 🍔\n\n'
          'You can open the Menu and add it to your cart.';
    }

    if (text.contains('pizza')) {
      return 'Pizza is a great choice! 🍕\n\n'
          'Check our Pizza category in the Menu for different options.';
    }

    if (text.contains('biryani')) {
      return 'Our Biryani options are perfect if you want something traditional. 🍛\n\n'
          'You can find them under the Rice category.';
    }

    if (text.contains('order')) {
      return 'You can select your food from the Menu, add items to your cart, '
          'and proceed with your order.';
    }

    if (text.contains('cart')) {
      return 'Your Cart contains the items you have selected. 🛒\n\n'
          'You can increase or decrease quantities before checkout.';
    }

    if (text.contains('delivery')) {
      return 'AFZ helps you order your favorite food conveniently. 🚴\n\n'
          'You can provide your delivery information during the ordering process.';
    }

    if (text.contains('offer') ||
        text.contains('discount') ||
        text.contains('deal')) {
      return 'Keep an eye on the Home screen for special offers and discounts. 🎉';
    }

    if (text.contains('favorite')) {
      return 'You can save your favorite food items ❤️ and easily find them again later.';
    }

    if (text.contains('help') || text.contains('how') || text.contains('app')) {
      return 'I can help you with:\n\n'
          '🍔 Choosing food\n'
          '🛒 Cart and ordering\n'
          '❤️ Favorites\n'
          '🚴 Delivery\n'
          '🎁 Offers\n'
          '📱 Using the AFZ app\n\n'
          'Just ask me anything!';
    }

    if (text.contains('hello') || text.contains('hi') || text.contains('hey')) {
      return 'Hello! 👋 What are you craving today? I can help you choose something from AFZ.';
    }

    return 'I’m here to help! 😊\n\n'
        'You can ask me about our menu, food recommendations, '
        'cart, orders, delivery, favorites, offers, or how to use the AFZ app.';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.82,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 15, 12),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF642F),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AFZ AI Assistant',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your food & app assistant',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(18),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final bool isAI = message['isAI'] as bool;

                return Align(
                  alignment: isAI
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 310),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isAI
                          ? const Color(0xFFFFF1EB)
                          : const Color(0xFFFF642F),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isAI ? 4 : 18),
                        bottomRight: Radius.circular(isAI ? 18 : 4),
                      ),
                    ),
                    child: Text(
                      message['message'],
                      style: TextStyle(
                        color: isAI ? Colors.black87 : Colors.white,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(
            height: 45,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              children: [
                _suggestion('🍔 Suggest a burger'),
                _suggestion('🍕 Suggest pizza'),
                _suggestion('🛒 How to order?'),
                _suggestion('🎁 Show offers'),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask AFZ AI...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF642F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestion(String text) {
    return GestureDetector(
      onTap: () {
        messageController.text = text;
        sendMessage();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN STATE
// ============================================================

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> cartItems = [];
  final List<Map<String, dynamic>> favoriteItems = [];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Burgers', 'icon': Icons.lunch_dining_rounded},
    {'name': 'Pizza', 'icon': Icons.local_pizza_rounded},
    {'name': 'Biryani', 'icon': Icons.rice_bowl_rounded},
    {'name': 'BBQ', 'icon': Icons.outdoor_grill_rounded},
    {'name': 'Drinks', 'icon': Icons.local_drink_rounded},
    {'name': 'Desserts', 'icon': Icons.icecream_rounded},
  ];

  final List<Map<String, dynamic>> popularItems = [
    {
      'name': 'Classic Beef Burger',
      'price': 'Rs. 650',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
    },
    {
      'name': 'Chicken Pizza',
      'price': 'Rs. 1,250',
      'rating': '4.9',
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
    },
    {
      'name': 'Chicken Biryani',
      'price': 'Rs. 450',
      'rating': '4.7',
      'image':
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
    },
  ];

  // ============================================================
  // OPEN MENU
  // ============================================================

  void _openMenu() {
    setState(() {
      selectedIndex = 1;
    });
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  void _addToCart(Map<String, dynamic> item) {
    if (widget.isGuest) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      final index = cartItems.indexWhere(
        (cartItem) => cartItem['name'] == item['name'],
      );

      if (index != -1) {
        cartItems[index]['quantity'] = (cartItems[index]['quantity'] ?? 1) + 1;
      } else {
        cartItems.add({...item, 'quantity': 1});
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFFF642F),
      ),
    );
  }

  // ============================================================
  // CART
  // ============================================================

  void _showCart() {
    if (widget.isGuest) {
      _showLoginRequiredDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double total = 0;

            for (final item in cartItems) {
              final price = _getPrice(item['price']);
              final quantity = item['quantity'] ?? 1;

              total += price * quantity;
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Your Cart',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: cartItems.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 65,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Add something delicious!',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                final quantity = item['quantity'] ?? 1;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.network(
                                          item['image'],
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 70,
                                                  height: 70,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.restaurant,
                                                    color: Colors.grey,
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
                                              item['name'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              _formatPrice(
                                                _getPrice(item['price']),
                                              ),
                                              style: const TextStyle(
                                                color: Color(0xFFFF642F),
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setModalState(() {
                                                      if (quantity > 1) {
                                                        cartItems[index]['quantity'] =
                                                            quantity - 1;
                                                      } else {
                                                        cartItems.removeAt(
                                                          index,
                                                        );
                                                      }
                                                    });

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(
                                                  width: 32,
                                                  child: Center(
                                                    child: Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                GestureDetector(
                                                  onTap: () {
                                                    setModalState(() {
                                                      cartItems[index]['quantity'] =
                                                          quantity + 1;
                                                    });

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFF642F,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          setModalState(() {
                                            cartItems.removeAt(index);
                                          });

                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    if (cartItems.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _formatPrice(total),
                                  style: const TextStyle(
                                    color: Color(0xFFFF642F),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Checkout coming soon'),
                                      backgroundColor: Color(0xFFFF642F),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF642F),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _getPrice(dynamic price) {
    if (price is num) {
      return price.toDouble();
    }

    if (price == null) {
      return 0;
    }

    String value = price.toString();

    value = value
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(value) ?? 0;
  }

  String _formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(0)}';
  }

  // ============================================================
  // AI HELP
  // ============================================================

  void _showAIHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return const _AFZAIChat();
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          _homePage(),

          CustomerMenuScreen(
            isGuest: widget.isGuest,
            favoriteItems: favoriteItems,
            onFavoritesChanged: () {
              setState(() {});
            },
            cartItems: cartItems,
            onCartChanged: () {
              setState(() {});
            },
          ),

          _guestProtectedPage('My Orders', Icons.receipt_long_rounded),

          widget.isGuest
              ? _guestProtectedPage('Favorites', Icons.favorite_rounded)
              : CustomerFavoritesScreen(
                  favoriteItems: favoriteItems,
                  onFavoritesChanged: () {
                    setState(() {});
                  },
                ),

          widget.isGuest
              ? _guestProtectedPage('Profile', Icons.person_rounded)
              : const CustomerProfileScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,

          onTap: (index) {
            if (widget.isGuest && index >= 2) {
              _showLoginRequiredDialog();
              return;
            }

            setState(() {
              selectedIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF642F),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 10,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HOME PAGE
  // ============================================================

  Widget _homePage() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _topHeader()),
          SliverToBoxAdapter(child: _heroBanner()),
          SliverToBoxAdapter(child: _categories()),
          SliverToBoxAdapter(
            child: _sectionTitle('Popular Near You', 'View all'),
          ),
          SliverToBoxAdapter(child: _popularItems()),
          SliverToBoxAdapter(child: _offerBanner()),
          SliverToBoxAdapter(
            child: _sectionTitle('Recommended For You', 'View all'),
          ),
          SliverToBoxAdapter(child: _recommendedCard()),
          SliverToBoxAdapter(child: _aiAssistant()),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget _topHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVER TO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 17,
                          color: Color(0xFFFF642F),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Your location',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ],
                ),
              ),

              // CART BUTTON
              GestureDetector(
                onTap: _showCart,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF222222),
                        ),
                      ),

                      if (cartItems.isNotEmpty)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 17,
                              minHeight: 17,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF642F),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${_cartCount()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for food, dishes...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFFF642F),
                ),
                suffixIcon: const Icon(Icons.tune_rounded, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _cartCount() {
    int count = 0;

    for (final item in cartItems) {
      count += (item['quantity'] ?? 1) as int;
    }

    return count;
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _heroBanner() {
    return Container(
      height: 210,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.black.withOpacity(0.15),
            ],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GOOD FOOD',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Made for your cravings.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Explore delicious meals from AFZ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _categories() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return Container(
            width: 78,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    category['icon'],
                    color: const Color(0xFFFF642F),
                    size: 29,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),

          GestureDetector(
            onTap: _openMenu,
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFFFF642F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // POPULAR ITEMS
  // ============================================================

  Widget _popularItems() {
    return SizedBox(
      height: 255,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: popularItems.length,
        itemBuilder: (context, index) {
          final item = popularItems[index];

          return Container(
            width: 205,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(21),
                  ),
                  child: Image.network(
                    item['image'],
                    height: 135,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 135,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.restaurant, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFB000),
                          ),

                          const SizedBox(width: 3),

                          Text(
                            item['rating'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            item['price'],
                            style: const TextStyle(
                              color: Color(0xFFFF642F),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // OFFER
  // ============================================================

  Widget _offerBanner() {
    return Container(
      height: 125,
      margin: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF292929), Color(0xFF111111)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPECIAL OFFER',
                  style: TextStyle(
                    color: Color(0xFFFF8A63),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Get 20% OFF\nYour First Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFF642F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                '20%\nOFF',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECOMMENDED CARD
  // ============================================================

  Widget _recommendedCard() {
    final item = {
      'name': 'Chicken Cheese Pizza',
      'price': 1450,
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item['image'] as String,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant, color: Colors.grey),
                );
              },
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chicken Cheese Pizza',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                SizedBox(height: 6),
                Text(
                  'Recommended based on popular choices',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                SizedBox(height: 10),
                Text(
                  'Rs. 1,450',
                  style: TextStyle(
                    color: Color(0xFFFF642F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // ADD BUTTON
          GestureDetector(
            onTap: () {
              _addToCart(item);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFF642F),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI ASSISTANT
  // ============================================================

  Widget _aiAssistant() {
    return GestureDetector(
      onTap: () {
        if (widget.isGuest) {
          _showLoginRequiredDialog();
          return;
        }

        _showAIHelp();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0EA), Color(0xFFFFF8F5)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFD6C7)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFF642F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask AFZ AI',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Need help choosing what to eat?',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFFF642F),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GUEST PAGE
  // ============================================================

  Widget _guestProtectedPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 70, color: const Color(0xFFFF642F)),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 10),

          if (widget.isGuest)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please login or create an account to access this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN REQUIRED
  // ============================================================

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(
            'Login Required',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),

          content: const Text(
            'You are browsing as a guest. Please login or create an account to continue.',
            style: TextStyle(color: Colors.grey, height: 1.4),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF642F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
