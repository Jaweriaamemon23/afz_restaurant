import 'package:flutter/material.dart';

class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Burgers',
    'Pizza',
    'Biryani',
    'BBQ',
    'Drinks',
    'Desserts',
  ];

  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Classic Beef Burger',
      'category': 'Burgers',
      'price': 850,
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
      'description':
          'Juicy beef patty with fresh lettuce, cheese, tomato and special sauce.',
      'popular': true,
    },
    {
      'name': 'Cheese Pizza',
      'category': 'Pizza',
      'price': 1450,
      'rating': 4.9,
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      'description':
          'Freshly baked pizza topped with mozzarella cheese and tomato sauce.',
      'popular': true,
    },
    {
      'name': 'Chicken Biryani',
      'category': 'Biryani',
      'price': 650,
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
      'description':
          'Traditional aromatic basmati rice cooked with spicy chicken and herbs.',
      'popular': true,
    },
    {
      'name': 'BBQ Platter',
      'category': 'BBQ',
      'price': 2200,
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
      'description':
          'A delicious selection of grilled BBQ items served with sauces.',
      'popular': false,
    },
    {
      'name': 'Fresh Lemonade',
      'category': 'Drinks',
      'price': 350,
      'rating': 4.6,
      'image':
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800',
      'description': 'Refreshing homemade lemonade served chilled.',
      'popular': false,
    },
    {
      'name': 'Chocolate Cake',
      'category': 'Desserts',
      'price': 550,
      'rating': 4.9,
      'image':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
      'description':
          'Rich and creamy chocolate cake perfect for ending your meal.',
      'popular': true,
    },
    {
      'name': 'Chicken Burger',
      'category': 'Burgers',
      'price': 750,
      'rating': 4.7,
      'image':
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=800',
      'description':
          'Crispy chicken fillet with lettuce, cheese and creamy sauce.',
      'popular': false,
    },
    {
      'name': 'Pepperoni Pizza',
      'category': 'Pizza',
      'price': 1650,
      'rating': 4.8,
      'image':
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800',
      'description':
          'Classic pizza loaded with mozzarella cheese and pepperoni.',
      'popular': true,
    },
  ];

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showFoodDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: Image.network(
                  item['image'],
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                          Text(
                            'Rs. ${item['price']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF642F),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${item['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF642F).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['category'],
                              style: const TextStyle(
                                color: Color(0xFFFF642F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'About this item',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        item['description'],
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('${item['name']} added to cart'),
                                backgroundColor: const Color(0xFFFF642F),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF642F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Our Menu',
          style: TextStyle(
            color: Color(0xFF222222),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: searchController,
              onChanged: (_) {
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
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10, bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF642F)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFF642F)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          // Menu
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No food found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return GestureDetector(
                        onTap: () => showFoodDetails(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Food Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: Image.network(
                                      item['image'],
                                      height: 145,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 145,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.restaurant,
                                                size: 45,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),

                                  if (item['popular'] == true)
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF642F),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Popular',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.12,
                                            ),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.favorite_border,
                                        size: 19,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['category'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFFF642F),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

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

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${item['rating']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Spacer(),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rs. ${item['price']}',
                                            style: const TextStyle(
                                              color: Color(0xFFFF642F),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF642F),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 21,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
