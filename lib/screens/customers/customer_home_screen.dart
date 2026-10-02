import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          _homePage(),
          _simplePage('Menu', Icons.restaurant_menu_rounded),
          _simplePage('My Orders', Icons.receipt_long_rounded),
          _simplePage('Favorites', Icons.favorite_rounded),
          _simplePage('Profile', Icons.person_rounded),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
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

              // Cart
              Container(
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
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF642F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Search
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
              'Made for your\\ncravings.',
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
          Text(
            action,
            style: const TextStyle(
              color: Color(0xFFFF642F),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

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
                  'Get 20% OFF\\nYour First Order',
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
                '20%\\nOFF',
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

  Widget _recommendedCard() {
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
              'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
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

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFF642F),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _aiAssistant() {
    return Container(
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
    );
  }

  Widget _simplePage(String title, IconData icon) {
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
        ],
      ),
    );
  }
}
