import 'package:flutter/material.dart';

class CustomerFavoritesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteItems;
  final VoidCallback onFavoritesChanged;

  const CustomerFavoritesScreen({
    super.key,
    required this.favoriteItems,
    required this.onFavoritesChanged,
  });

  @override
  State<CustomerFavoritesScreen> createState() =>
      _CustomerFavoritesScreenState();
}

class _CustomerFavoritesScreenState extends State<CustomerFavoritesScreen> {
  void removeFavorite(int index) {
    setState(() {
      widget.favoriteItems.removeAt(index);
    });

    widget.onFavoritesChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: widget.favoriteItems.isEmpty
          ? _emptyFavorites()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.favoriteItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final item = widget.favoriteItems[index];

                return _favoriteCard(item, index);
              },
            ),
    );
  }

  Widget _favoriteCard(Map<String, dynamic> item, int index) {
    return Container(
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
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    item['image'] ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 45,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // REMOVE FAVORITE
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF642F),
                      ),
                      onPressed: () {
                        removeFavorite(index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DETAILS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'Rs. ${item['price'] ?? ''}',
                  style: const TextStyle(
                    color: Color(0xFFFF642F),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 15),

          const Text(
            'No Favorites Yet',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Add your favorite food items from the menu.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
