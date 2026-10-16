import 'dart:async';

import 'package:flutter/material.dart';

import '../login_screen.dart';
import '../checkout_screen.dart';
import '../../services/menu_service.dart';

class CustomerMenuScreen extends StatefulWidget {
  final bool isGuest;
  final List<Map<String, dynamic>> favoriteItems;
  final VoidCallback onFavoritesChanged;
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCartChanged;

  const CustomerMenuScreen({
    super.key,
    this.isGuest = false,
    required this.favoriteItems,
    required this.onFavoritesChanged,
    required this.cartItems,
    required this.onCartChanged,
  });

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  static const Color orange = Color(0xFFFF642F);
  static const Color background = Color(0xFFF8F8F8);

  static const double menuImageHeight = 150;

  final TextEditingController searchController = TextEditingController();

  StreamSubscription<List<Map<String, dynamic>>>? _menuSubscription;

  String selectedCategory = 'All';
  List<Map<String, dynamic>> menuItems = [];
  bool isLoadingMenu = true;
  String? menuError;

  List<String> get categories {
    final dynamicCategories =
        menuItems
            .map((item) => (item['category'] ?? '').toString().trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return ['All', ...dynamicCategories];
  }

  @override
  void initState() {
    super.initState();
    _subscribeToMenu();
  }

  void _subscribeToMenu() {
    _menuSubscription?.cancel();

    _menuSubscription = MenuService.instance.watchAvailableMenuItems().listen(
      (items) {
        if (!mounted) return;

        setState(() {
          menuItems = items;

          if (selectedCategory != 'All' &&
              !items.any(
                (item) =>
                    (item['category'] ?? '').toString().trim().toLowerCase() ==
                    selectedCategory.trim().toLowerCase(),
              )) {
            selectedCategory = 'All';
          }

          isLoadingMenu = false;
          menuError = null;
        });
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoadingMenu = false;
          menuError = error.toString();
        });
      },
    );
  }

  List<Map<String, dynamic>> get filteredItems {
    final searchText = searchController.text.trim().toLowerCase();

    return menuItems.where((item) {
      final category = (item['category'] ?? '').toString();
      final name = (item['name'] ?? '').toString().toLowerCase();

      final matchesCategory =
          selectedCategory == 'All' ||
          category.trim().toLowerCase() ==
              selectedCategory.trim().toLowerCase();

      return matchesCategory && name.contains(searchText);
    }).toList();
  }

  int get cartItemCount {
    int count = 0;

    for (final item in widget.cartItems) {
      count += (item['quantity'] as num?)?.toInt() ?? 0;
    }

    return count;
  }

  double get cartTotal {
    double total = 0;

    for (final item in widget.cartItems) {
      final price = (item['price'] as num?)?.toDouble() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      total += price * quantity;
    }

    return total;
  }

  void showLoginRequiredDialog({
    String message = 'Please login or create an account to continue.',
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: orange),
            SizedBox(width: 10),
            Expanded(child: Text('Login Required')),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void addToCart(Map<String, dynamic> item) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to add items to your cart.',
      );
      return;
    }

    final itemName = (item['name'] ?? '').toString();

    final existingIndex = widget.cartItems.indexWhere(
      (cartItem) => cartItem['name'] == itemName,
    );

    if (existingIndex >= 0) {
      final quantity =
          (widget.cartItems[existingIndex]['quantity'] as num?)?.toInt() ?? 1;

      widget.cartItems[existingIndex]['quantity'] = quantity + 1;
    } else {
      widget.cartItems.add({...item, 'quantity': 1});
    }

    widget.onCartChanged();

    if (mounted) {
      setState(() {});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: orange,
      ),
    );
  }

  void increaseQuantity(int index) {
    final quantity =
        (widget.cartItems[index]['quantity'] as num?)?.toInt() ?? 1;

    widget.cartItems[index]['quantity'] = quantity + 1;
    widget.onCartChanged();

    if (mounted) setState(() {});
  }

  void decreaseQuantity(int index) {
    final quantity =
        (widget.cartItems[index]['quantity'] as num?)?.toInt() ?? 1;

    if (quantity > 1) {
      widget.cartItems[index]['quantity'] = quantity - 1;
    } else {
      widget.cartItems.removeAt(index);
    }

    widget.onCartChanged();

    if (mounted) setState(() {});
  }

  void removeFromCart(int index) {
    widget.cartItems.removeAt(index);
    widget.onCartChanged();

    if (mounted) setState(() {});
  }

  void toggleFavorite(Map<String, dynamic> item) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to save items to your favorites.',
      );
      return;
    }

    final itemName = (item['name'] ?? '').toString();

    setState(() {
      final index = widget.favoriteItems.indexWhere(
        (favorite) => favorite['name'] == itemName,
      );

      if (index >= 0) {
        widget.favoriteItems.removeAt(index);
      } else {
        widget.favoriteItems.add(Map<String, dynamic>.from(item));
      }
    });

    widget.onFavoritesChanged();
  }

  // All image areas have fixed dimensions.
  // BoxFit.cover fills the complete box consistently.
  Widget foodImage(
    String imageUrl, {
    required double height,
    double? width,
    double iconSize = 55,
    BoxFit fit = BoxFit.cover,
  }) {
    final url = imageUrl.trim();

    if (url.isEmpty) {
      return _imagePlaceholder(height, width, iconSize);
    }

    return SizedBox(
      height: height,
      width: width,
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        alignment: Alignment.center,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            height: height,
            width: width,
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: orange,
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder(height, width, iconSize);
        },
      ),
    );
  }

  Widget _imagePlaceholder(double height, double? width, double iconSize) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Icon(Icons.fastfood, size: iconSize, color: orange),
    );
  }

  void showFoodDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        final name = (item['name'] ?? 'Unnamed Item').toString();
        final image = (item['image'] ?? '').toString();
        final description = (item['description'] ?? 'No description available.')
            .toString();
        final price = item['price'] ?? 0;

        return SafeArea(
          child: SingleChildScrollView(
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
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: foodImage(
                    image,
                    height: 210,
                    width: double.infinity,
                    iconSize: 70,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rs. $price',
                  style: const TextStyle(
                    color: orange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      addToCart(item);
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      widget.isGuest ? 'Login to Add to Cart' : 'Add to Cart',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      builder: (sheetContext) {
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
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: widget.cartItems.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 65,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 12),
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
                              itemCount: widget.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.cartItems[index];

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: foodImage(
                                            (item['image'] ?? '').toString(),
                                            width: 60,
                                            height: 60,
                                            iconSize: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (item['name'] ?? 'Item')
                                                    .toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Rs. ${item['price'] ?? 0}',
                                                style: const TextStyle(
                                                  color: orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            decreaseQuantity(index);
                                            setModalState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                        ),
                                        Text(
                                          '${item['quantity'] ?? 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            increaseQuantity(index);
                                            setModalState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.add_circle,
                                            color: orange,
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
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
                    if (widget.cartItems.isNotEmpty) ...[
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
                              color: orange,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final checkoutItems = widget.cartItems
                                .map((item) => Map<String, dynamic>.from(item))
                                .toList();

                            Navigator.pop(sheetContext);

                            Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  cartItems: checkoutItems,
                                  onOrderPlaced: () {
                                    widget.cartItems.clear();
                                    widget.onCartChanged();

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
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

  Widget _buildMenuCard(Map<String, dynamic> item) {
    final name = (item['name'] ?? '').toString();
    final category = (item['category'] ?? '').toString();
    final image = (item['image'] ?? '').toString();
    final price = item['price'] ?? 0;
    final description = (item['description'] ?? '').toString().trim();

    final isFavorite = widget.favoriteItems.any(
      (favorite) => favorite['name'] == name,
    );

    return GestureDetector(
      onTap: () => showFoodDetails(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Every menu image uses exactly the same height.
            SizedBox(
              height: menuImageHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  foodImage(
                    image,
                    height: menuImageHeight,
                    width: double.infinity,
                    iconSize: 45,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => toggleFavorite(item),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 14,
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 34,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 28,
                      child: Text(
                        description.isEmpty
                            ? 'No description available'
                            : description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Rs. $price',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: orange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => addToCart(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.isGuest ? 'Login to Order' : 'Add to Cart',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildMenuBody() {
    if (isLoadingMenu) {
      return const Center(child: CircularProgressIndicator(color: orange));
    }

    if (menuError != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 55, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Unable to load menu from Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                menuError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoadingMenu = true;
                    menuError = null;
                  });
                  _subscribeToMenu();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              menuItems.isEmpty
                  ? 'No menu items available yet'
                  : 'No food items found',
              style: const TextStyle(color: Colors.grey, fontSize: 17),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700 ? 3 : 2;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: crossAxisCount == 2 ? 0.69 : 0.76,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return _buildMenuCard(filteredItems[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
                      color: orange,
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
          if (widget.isGuest)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You are browsing as a guest. Login to order food and save favorites.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon: const Icon(Icons.search, color: orange),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: orange,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 2),
          Expanded(child: _buildMenuBody()),
        ],
      ),
    );
  }
}
