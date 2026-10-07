import 'package:flutter/material.dart';
import '../login_screen.dart';

class CustomerMenuScreen extends StatefulWidget {
  final bool isGuest;

  // Favorites controlled by HomeScreen
  final List<Map<String, dynamic>> favoriteItems;

  // Tells HomeScreen that favorites changed
  final VoidCallback onFavoritesChanged;

  // Shared cart controlled by HomeScreen
  final List<Map<String, dynamic>> cartItems;

  // Tells HomeScreen that cart changed
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
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  // ============================================================
  // MENU ITEMS
  // ============================================================

  final List<Map<String, dynamic>> menuItems = [
    // ================= BURGERS =================
    {
      'name': 'Classic Beef Burger',
      'category': 'Burgers',
      'price': 850,
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=80',
      'description':
          'Juicy beef patty with fresh lettuce, tomato and special sauce.',
    },
    {
      'name': 'Chicken Burger',
      'category': 'Burgers',
      'price': 750,
      'image':
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=80',
      'description':
          'Crispy chicken fillet with lettuce, cheese and creamy sauce.',
    },
    {
      'name': 'Zinger Burger',
      'category': 'Burgers',
      'price': 800,
      'image':
          'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80',
      'description':
          'Crispy spicy chicken burger with fresh vegetables and sauce.',
    },
    {
      'name': 'Cheese Beef Burger',
      'category': 'Burgers',
      'price': 950,
      'image':
          'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?auto=format&fit=crop&w=800&q=80',
      'description':
          'Double cheese and juicy beef patty with our signature sauce.',
    },
    {
      'name': 'Double Beef Burger',
      'category': 'Burgers',
      'price': 1150,
      'image':
          'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=800&q=80',
      'description':
          'Two delicious beef patties with cheese and fresh toppings.',
    },
    {
      'name': 'BBQ Chicken Burger',
      'category': 'Burgers',
      'price': 900,
      'image':
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?auto=format&fit=crop&w=800&q=80',
      'description':
          'Grilled chicken with smoky BBQ sauce and crunchy vegetables.',
    },

    // ================= PIZZA =================
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'price': 1200,
      'image':
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80',
      'description':
          'Classic pizza loaded with mozzarella cheese and tomato sauce.',
    },
    {
      'name': 'Pepperoni Pizza',
      'category': 'Pizza',
      'price': 1450,
      'image':
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&w=800&q=80',
      'description':
          'Classic pepperoni with mozzarella cheese and rich tomato sauce.',
    },
    {
      'name': 'Chicken Tikka Pizza',
      'category': 'Pizza',
      'price': 1400,
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
      'description': 'Chicken tikka, onions, capsicum and mozzarella cheese.',
    },
    {
      'name': 'BBQ Chicken Pizza',
      'category': 'Pizza',
      'price': 1500,
      'image':
          'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=800&q=80',
      'description': 'Smoky BBQ chicken with onions, cheese and BBQ sauce.',
    },
    {
      'name': 'Fajita Pizza',
      'category': 'Pizza',
      'price': 1550,
      'image':
          'https://img.sndimg.com/food/image/upload/f_auto,c_thumb,q_55,w_744,ar_5:4/v1/img/submissions/recipe/0/3BMAdEClTbOG6Dhj9zf7_Grilled%20Chicken%20Fajita%20Pizza.jpg',
      'description': 'Spicy chicken fajita with capsicum, onions and cheese.',
    },
    {
      'name': 'Vegetable Pizza',
      'category': 'Pizza',
      'price': 1150,
      'image':
          'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=800&q=80',
      'description': 'Fresh capsicum, onions, tomatoes, olives and mozzarella.',
    },

    // ================= RICE =================
    {
      'name': 'Chicken Biryani',
      'category': 'Rice',
      'price': 450,
      'image':
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=80',
      'description':
          'Traditional Pakistani chicken biryani with aromatic basmati rice.',
    },
    {
      'name': 'Beef Biryani',
      'category': 'Rice',
      'price': 550,
      'image':
          'https://pakistani.recipes/images/recipes/beef-biryani-karachi.webp',
      'description': 'Spicy beef biryani prepared with aromatic spices.',
    },
    {
      'name': 'Mutton Biryani',
      'category': 'Rice',
      'price': 650,
      'image':
          'https://images.unsplash.com/photo-1631515242808-497c3fbd3972?auto=format&fit=crop&w=800&q=80',
      'description':
          'Tender mutton with fragrant basmati rice and traditional spices.',
    },
    {
      'name': 'Chicken Pulao',
      'category': 'Rice',
      'price': 450,
      'image':
          'https://images.deliveryhero.io/image/fd-pk/Products/76532734.jpg?width=800',
      'description': 'Light and flavorful chicken pulao with aromatic rice.',
    },
    {
      'name': 'Beef Pulao',
      'category': 'Rice',
      'price': 550,
      'image': 'https://miro.medium.com/1%2AivSvixMh_cTtGI6jDYkDzw.jpeg',
      'description':
          'Tender beef cooked with flavorful basmati rice and spices.',
    },

    // ================= BBQ =================
    {
      'name': 'BBQ Platter',
      'category': 'BBQ',
      'price': 1800,
      'image':
          'https://fainemisto.com/media/uploads/2024/08/27/zamoviti-zhu.jpg',
      'description':
          'A delicious combination of grilled chicken, kebabs and BBQ items.',
    },
    {
      'name': 'Chicken Tikka',
      'category': 'BBQ',
      'price': 650,
      'image':
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=800&q=80',
      'description':
          'Tender chicken pieces marinated with traditional spices and grilled.',
    },
    {
      'name': 'Chicken Seekh Kebab',
      'category': 'BBQ',
      'price': 600,
      'image':
          'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80',
      'description': 'Juicy minced chicken kebabs grilled to perfection.',
    },
    {
      'name': 'Beef Seekh Kebab',
      'category': 'BBQ',
      'price': 700,
      'image':
          'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80',
      'description':
          'Traditional spicy beef seekh kebabs served hot from the grill.',
    },
    {
      'name': 'Malai Boti',
      'category': 'BBQ',
      'price': 850,
      'image':
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=800&q=80',
      'description':
          'Creamy and tender chicken pieces grilled with mild spices.',
    },

    // ================= FAST FOOD =================
    {
      'name': 'Chicken Shawarma',
      'category': 'Fast Food',
      'price': 450,
      'image':
          'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?auto=format&fit=crop&w=800&q=80',
      'description':
          'Juicy chicken wrapped with fresh vegetables and garlic sauce.',
    },
    {
      'name': 'Chicken Wrap',
      'category': 'Fast Food',
      'price': 500,
      'image':
          'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80',
      'description':
          'Grilled chicken, vegetables and creamy sauce wrapped in soft bread.',
    },
    {
      'name': 'Chicken Nuggets',
      'category': 'Fast Food',
      'price': 550,
      'image':
          'https://images.unsplash.com/photo-1562967916-eb82221dfb92?auto=format&fit=crop&w=800&q=80',
      'description': 'Crispy golden chicken nuggets served with dipping sauce.',
    },
    {
      'name': 'French Fries',
      'category': 'Fast Food',
      'price': 300,
      'image':
          'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=800&q=80',
      'description':
          'Crispy golden fries lightly seasoned with our special seasoning.',
    },
    {
      'name': 'Loaded Fries',
      'category': 'Fast Food',
      'price': 550,
      'image':
          'https://images.unsplash.com/photo-1585109649139-366815a0d713?auto=format&fit=crop&w=800&q=80',
      'description':
          'Crispy fries topped with cheese, chicken and special sauces.',
    },

    // ================= DRINKS =================
    {
      'name': 'Fresh Lemonade',
      'category': 'Drinks',
      'price': 250,
      'image':
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=800&q=80',
      'description': 'Refreshing homemade lemonade served chilled.',
    },
    {
      'name': 'Mango Shake',
      'category': 'Drinks',
      'price': 400,
      'image':
          'https://images.unsplash.com/photo-1546173159-315724a31696?auto=format&fit=crop&w=800&q=80',
      'description': 'Creamy mango shake made with fresh mangoes.',
    },
    {
      'name': 'Chocolate Shake',
      'category': 'Drinks',
      'price': 450,
      'image':
          'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=800&q=80',
      'description': 'Rich and creamy chocolate milkshake.',
    },
    {
      'name': 'Fresh Orange Juice',
      'category': 'Drinks',
      'price': 300,
      'image':
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=800&q=80',
      'description': 'Freshly squeezed orange juice served chilled.',
    },
    {
      'name': 'Mint Margarita',
      'category': 'Drinks',
      'price': 350,
      'image':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
      'description': 'Cool and refreshing mint drink with lemon.',
    },

    // ================= DESSERTS =================
    {
      'name': 'Chocolate Cake',
      'category': 'Desserts',
      'price': 400,
      'image':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=800&q=80',
      'description': 'Rich chocolate cake with creamy chocolate frosting.',
    },
    {
      'name': 'Chocolate Brownie',
      'category': 'Desserts',
      'price': 350,
      'image':
          'https://images.unsplash.com/photo-1564355808539-22fda35bed7e?auto=format&fit=crop&w=800&q=80',
      'description': 'Warm fudgy chocolate brownie.',
    },
    {
      'name': 'Cheesecake',
      'category': 'Desserts',
      'price': 500,
      'image':
          'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=800&q=80',
      'description': 'Creamy cheesecake with a delicious biscuit base.',
    },
    {
      'name': 'Ice Cream Sundae',
      'category': 'Desserts',
      'price': 450,
      'image':
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=800&q=80',
      'description': 'Creamy ice cream topped with chocolate and nuts.',
    },
    {
      'name': 'Chocolate Lava Cake',
      'category': 'Desserts',
      'price': 550,
      'image':
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80',
      'description': 'Warm chocolate cake with a rich molten chocolate center.',
    },
  ];

  // ============================================================
  // FILTERED ITEMS
  // ============================================================

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

  // ============================================================
  // CART
  // ============================================================

  int get cartItemCount {
    int count = 0;

    for (final item in widget.cartItems) {
      count += item['quantity'] as int;
    }

    return count;
  }

  double get cartTotal {
    double total = 0;

    for (final item in widget.cartItems) {
      total += (item['price'] as num).toDouble() * (item['quantity'] as int);
    }

    return total;
  }

  // ============================================================
  // LOGIN DIALOG
  // ============================================================

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

  // ============================================================
  // ADD TO CART
  // ============================================================

  void addToCart(Map<String, dynamic> item) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to add items to your cart.',
      );
      return;
    }

    final existingIndex = widget.cartItems.indexWhere(
      (cartItem) => cartItem['name'] == item['name'],
    );

    if (existingIndex >= 0) {
      widget.cartItems[existingIndex]['quantity']++;
    } else {
      widget.cartItems.add({...item, 'quantity': 1});
    }

    // Tell Home that the shared cart changed.
    widget.onCartChanged();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFFF642F),
      ),
    );
  }

  // ============================================================
  // QUANTITY
  // ============================================================

  void increaseQuantity(int index) {
    widget.cartItems[index]['quantity']++;

    widget.onCartChanged();

    setState(() {});
  }

  void decreaseQuantity(int index) {
    if (widget.cartItems[index]['quantity'] > 1) {
      widget.cartItems[index]['quantity']--;
    } else {
      widget.cartItems.removeAt(index);
    }

    widget.onCartChanged();

    setState(() {});
  }

  void removeFromCart(int index) {
    widget.cartItems.removeAt(index);

    widget.onCartChanged();

    setState(() {});
  }

  // ============================================================
  // FAVORITES
  // ============================================================

  void toggleFavorite(Map<String, dynamic> item) {
    if (widget.isGuest) {
      showLoginRequiredDialog(
        message: 'Please login to save items to your favorites.',
      );
      return;
    }

    setState(() {
      final existingIndex = widget.favoriteItems.indexWhere(
        (favorite) => favorite['name'] == item['name'],
      );

      if (existingIndex >= 0) {
        widget.favoriteItems.removeAt(existingIndex);
      } else {
        widget.favoriteItems.add(Map<String, dynamic>.from(item));
      }
    });

    widget.onFavoritesChanged();
  }

  // ============================================================
  // FOOD DETAILS
  // ============================================================

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
                child: Image.network(
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

  // ============================================================
  // CART BOTTOM SHEET
  // ============================================================

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
                      child: widget.cartItems.isEmpty
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
                              itemCount: widget.cartItems.length,
                              itemBuilder: (context, index) {
                                final item = widget.cartItems[index];

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
                                          child: Image.network(
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

  // ============================================================
  // DISPOSE
  // ========================================================

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      'All',
      'Burgers',
      'Pizza',
      'Rice',
      'BBQ',
      'Fast Food',
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
          if (widget.isGuest)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF642F)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are browsing as a guest. Login to order food and save favorites.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // SEARCH
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

          // CATEGORIES
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

          // MENU
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

                      final isFavorite = widget.favoriteItems.any(
                        (favorite) => favorite['name'] == item['name'],
                      );

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
                              // IMAGE
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Image.network(
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

                                  // FAVORITE
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
                                          toggleFavorite(item);
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
