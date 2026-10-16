import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../services/menu_seed_service.dart';
import 'add_menu_item_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  static const Color primary = Color(0xFFFF642F);
  static const Color pageBackground = Color(0xFFF7F7F8);

  bool _importing = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  Future<void> _addItem() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddMenuItemScreen()),
    );
  }

  Future<void> _importStarterItems() async {
    setState(() => _importing = true);

    try {
      final count = await MenuSeedService.instance.importStarterMenu();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'Starter menu is already imported.'
                : '$count starter items added to Firestore.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Import failed: $error')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _deleteItem(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete menu item?'),
        content: Text('Delete "$name" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await MenuService.instance.deleteMenuItem(id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu item deleted.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text(
          'Manage Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Import starter menu',
            onPressed: _importing ? null : _importStarterItems,
            icon: const Icon(
              Icons.download_for_offline_outlined,
              color: primary,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: MenuService.instance.watchMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Could not load menu: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          final items = snapshot.data!;

          final categories = <String>{
            'All',
            ...items
                .map(
                  (item) =>
                      (item['category'] ?? 'Uncategorized').toString().trim(),
                )
                .where((category) => category.isNotEmpty),
          }.toList();

          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'All';
          }

          final query = _searchQuery.trim().toLowerCase();

          final filteredItems = items.where((item) {
            final category = (item['category'] ?? 'Uncategorized')
                .toString()
                .trim();
            final name = (item['name'] ?? '').toString().toLowerCase();
            final description = (item['description'] ?? '')
                .toString()
                .toLowerCase();

            final matchesCategory =
                _selectedCategory == 'All' || category == _selectedCategory;
            final matchesSearch =
                name.contains(query) || description.contains(query);

            return matchesCategory && matchesSearch;
          }).toList();

          final availableCount = items
              .where((item) => item['isAvailable'] == true)
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SUMMARY HEADER
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF794D), primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Menu, Your Way',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Manage your dishes and availability',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _summaryBox(
                          'Total Items',
                          items.length.toString(),
                          Icons.restaurant_menu,
                        ),
                        const SizedBox(width: 12),
                        _summaryBox(
                          'Available',
                          availableCount.toString(),
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 12),
                        _summaryBox(
                          'Categories',
                          (categories.length - 1).toString(),
                          Icons.category_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search, color: primary),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // CATEGORY FILTERS
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category == _selectedCategory;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected ? primary : Colors.grey.shade200,
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // MENU ITEMS
              Expanded(
                child: items.isEmpty
                    ? _emptyMenu()
                    : filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found.',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;

                          final columns = width >= 1100
                              ? 4
                              : width >= 700
                              ? 3
                              : 2;

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: filteredItems.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: width < 380
                                      ? 0.56
                                      : width < 700
                                      ? 0.62
                                      : 0.72,
                                ),
                            itemBuilder: (context, index) {
                              return _menuCard(filteredItems[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(Map<String, dynamic> item) {
    final id = (item['id'] ?? '').toString();
    final name = (item['name'] ?? 'Unnamed item').toString();
    final category = (item['category'] ?? 'Uncategorized').toString();
    final description = (item['description'] ?? '').toString().trim();
    final price = item['price'] ?? 0;

    // Accept common image field names.
    final imageCandidates = [
      item['image'],
      item['imageUrl'],
      item['image_url'],
      item['photoUrl'],
    ];

    String image = '';
    for (final candidate in imageCandidates) {
      final url = (candidate ?? '').toString().trim();
      if (url.startsWith('https://') || url.startsWith('http://')) {
        image = url;
        break;
      }
    }

    final available = item['isAvailable'] == true;

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOOD IMAGE
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image.isNotEmpty)
                  Image.network(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;

                      return Container(
                        color: const Color(0xFFFFEEE8),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: primary,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  )
                else
                  _imageFallback(),

                // AVAILABILITY
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: available
                          ? const Color(0xFFE7F8EC)
                          : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      available ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: available
                            ? const Color(0xFF218838)
                            : Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ITEM OPTIONS
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: const CircleBorder(),
                    child: PopupMenuButton<String>(
                      tooltip: 'Manage item',
                      icon: const Icon(Icons.more_vert, size: 21),
                      onSelected: (value) async {
                        if (value == 'availability') {
                          try {
                            await MenuService.instance.setAvailability(
                              id,
                              !available,
                            );
                          } catch (error) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Update failed: $error')),
                            );
                          }
                        } else if (value == 'delete') {
                          await _deleteItem(id, name);
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'availability',
                          child: Text(
                            available ? 'Mark unavailable' : 'Mark available',
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete item'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DETAILS: CATEGORY, NAME, DESCRIPTION, PRICE
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ],

                  const SizedBox(height: 5),
                  Text(
                    'Rs. $price',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMenu() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 48,
                color: primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your menu is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import the original menu or add your first dish.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _importing ? null : _importStarterItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Import 37 Starter Items'),
            ),
            if (_importing) ...[
              const SizedBox(height: 12),
              const CircularProgressIndicator(color: primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFFFEEE8),
      alignment: Alignment.center,
      child: const Icon(Icons.fastfood, size: 42, color: primary),
    );
  }
}
