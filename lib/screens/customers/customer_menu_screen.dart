import 'package:flutter/material.dart';
import '../login_screen.dart';

class CustomerMenuScreen extends StatefulWidget {
  final bool isGuest;

  const CustomerMenuScreen({super.key, this.isGuest = false});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Classic Beef Burger',
      'category': 'Burgers',
      'price': 850,
      'image': 'assets/images/burger.jpg',
      'description':
          'Juicy beef patty with fresh vegetables and special sauce.',
    },
    {
      'name': 'Chicken Burger',
      'category': 'Burgers',
      'price': 750,
      'image': 'assets/images/chicken_burger.jpg',
      'description': 'Crispy chicken fillet with lettuce, cheese and sauce.',
    },
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'price': 1200,
      'image': 'assets/images/cheese_pizza.jpg',
      'description': 'Freshly baked pizza loaded with mozzarella cheese.',
    },
    {
      'name': 'Pepperoni Pizza',
      'category': 'Pizza',
      'price': 1450,
      'image': 'assets/images/pepperoni_pizza.jpg',
      'description': 'Classic pizza topped with pepperoni and mozzarella.',
    },
    {
      'name': 'Chicken Biryani',
      'category': 'Rice',
      'price': 450,
      'image': 'assets/images/biryani.jpg',
      'description': 'Aromatic basmati rice cooked with spicy chicken.',
    },
    {
      'name': 'BBQ Platter',
      'category': 'BBQ',
      'price': 1800,
      'image': 'assets/images/bbq.jpg',
      'description': 'A delicious platter of grilled BBQ specialties.',
    },
    {
      'name': 'Fresh Lemonade',
      'category': 'Drinks',
      'price': 250,
      'image': 'assets/images/lemonade.jpg',
      'description': 'Refreshing fresh lemonade served chilled.',
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Desserts',
      'price': 400,
      'image': 'assets/images/chocolate_cake.jpg',
      'description': 'Soft and rich chocolate cake with creamy topping.',
    },
  ];

  final List<Map<String, dynamic>> cartItems = [];
  final Set<String> favoriteItems = {};

  List<Map<String, dynamic>> get filteredItems {
    final searchText = searchController.text.toLowerCase();

    return menuItems.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item['category'] == selectedCategory;

      final matchesSearch = item['name'].toString().toLowerCase().contains(
        searchText,
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get cartItemCount {
    int count = 0;

    for (final item in cartItems) {
      count += item['quantity'] as int;
    }

    return count;
  }

  double get cartTotal {
    double total = 0;

    for (final item in cartItems) {
      total += (item['price'] as num).toDouble() * (item['quantity'] as int);
    }

    return total;
  }

  void showLoginRequiredDialog({
    String message = 'Please login or create an account to continue.',
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFFFF642F)),
              SizedBox(width: 10),
              Expanded(child: Text('Login Required')),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void addToCart(Map<String, dynamic> item) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to add items to your cart.',
      );
      return;
    }

    setState(() {
      final existingIndex = cartItems.indexWhere(
        (cartItem) => cartItem['name'] == item['name'],
      );

      if (existingIndex >= 0) {
        cartItems[existingIndex]['quantity']++;
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

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void toggleFavorite(String itemName) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to save items to your favorites.',
      );
      return;
    }

    setState(() {
      if (favoriteItems.contains(itemName)) {
        favoriteItems.remove(itemName);
      } else {
        favoriteItems.add(itemName);
      }
    });
  }

  void showFoodDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  item['image'],
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.fastfood,
                        size: 70,
                        color: Color(0xFFFF642F),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Rs. ${item['price']}',
                style: const TextStyle(
                  color: Color(0xFFFF642F),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                item['description'],
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    addToCart(item);
                  },
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(
                    widget.isGuest ? 'Login to Add to Cart' : 'Add to Cart',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF642F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void showCart() {
    if (widget.isGuest) {
      showLoginRequiredDialog(message: 'Please login to view your cart.');
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
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Cart',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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

                    const SizedBox(height: 10),

                    Expanded(
                      child: cartItems.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.asset(
                                            item['image'],
                                            width: 65,
                                            height: 65,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 65,
                                                    height: 65,
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.fastfood,
                                                      color: Color(0xFFFF642F),
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Rs. ${item['price']}',
                                                style: const TextStyle(
                                                  color: Color(0xFFFF642F),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                decreaseQuantity(index);
                                                setModalState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle,
                                              ),
                                            ),
                                            Text(
                                              '${item['quantity']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                increaseQuantity(index);
                                                setModalState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.add_circle,
                                                color: Color(0xFFFF642F),
                                              ),
                                            ),
                                          ],
                                        ),

                                        IconButton(
                                          onPressed: () {
                                            removeFromCart(index);
                                            setModalState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    if (cartItems.isNotEmpty) ...[
                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${cartTotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFF642F),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Checkout screen will be connected next.',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF642F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Burgers',
      'Pizza',
      'Rice',
      'BBQ',
      'Drinks',
      'Desserts',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: showCart,
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black,
                ),
              ),

              if (cartItemCount > 0 && !widget.isGuest)
                Positioned(
                  right: 4,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF642F),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Guest information
          if (widget.isGuest)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFF642F)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'You are browsing as a guest. Login to order food and save favorites.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF642F)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 55,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: const Color(0xFFFF642F),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          // Menu items
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'No food items found',
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      final isFavorite = favoriteItems.contains(item['name']);

                      return GestureDetector(
                        onTap: () => showFoodDetails(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Image.asset(
                                      item['image'],
                                      width: double.infinity,
                                      height: 145,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 145,
                                              width: double.infinity,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.fastfood,
                                                size: 55,
                                                color: Color(0xFFFF642F),
                                              ),
                                            );
                                          },
                                    ),
                                  ),

                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        constraints: const BoxConstraints(
                                          minWidth: 38,
                                          minHeight: 38,
                                        ),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          toggleFavorite(item['name']);
                                        },
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 21,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.all(11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['category'],
                                      style: const TextStyle(
                                        color: Color(0xFFFF642F),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      item['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      'Rs. ${item['price']}',
                                      style: const TextStyle(
                                        color: Color(0xFFFF642F),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 38,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          addToCart(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFFF642F,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          widget.isGuest
                                              ? 'Login to Order'
                                              : 'Add to Cart',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
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
                  ),
          ),
        ],
      ),
    );
  }
}
