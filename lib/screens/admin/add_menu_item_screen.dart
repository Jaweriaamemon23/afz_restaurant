import 'package:flutter/material.dart';
import '../../services/menu_service.dart';

class AddMenuItemScreen extends StatefulWidget {
  const AddMenuItemScreen({super.key});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  static const Color primary = Color(0xFFFF642F);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _image = TextEditingController();
  final _description = TextEditingController();
  final _customCategory = TextEditingController();

  String _category = 'Burgers';
  bool _addNewCategory = false;
  bool _available = true;
  bool _saving = false;

  final List<String> _categories = [
    'Burgers',
    'Pizza',
    'Rice',
    'BBQ',
    'Fast Food',
    'Drinks',
    'Desserts',
  ];

  String get _selectedCategory {
    if (_addNewCategory) {
      return _customCategory.text.trim();
    }
    return _category;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = _selectedCategory;

    setState(() => _saving = true);

    try {
      await MenuService.instance.addMenuItem({
        'name': _name.text.trim(),
        'category': category,
        'price': num.parse(_price.text.trim()),
        'image': _image.text.trim(),
        'description': _description.text.trim(),
        'isAvailable': _available,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menu item added to $category successfully.')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save menu item: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('Add Menu Item'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: _decoration('Item name'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter item name'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Select an existing category or create a new one.
                      DropdownButtonFormField<String>(
                        value: _addNewCategory ? '__new__' : _category,
                        decoration: _decoration('Category'),
                        items: [
                          ..._categories.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                          const DropdownMenuItem(
                            value: '__new__',
                            child: Text('+ Add New Category'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _addNewCategory = value == '__new__';

                            if (!_addNewCategory) {
                              _category = value;
                              _customCategory.clear();
                            }
                          });
                        },
                      ),

                      if (_addNewCategory) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _customCategory,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            'New category name',
                            hint: 'e.g. Arabian, Chinese, Pasta',
                          ),
                          validator: (value) {
                            if (_addNewCategory &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Enter a category name';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration('Price (Rs.)'),
                        validator: (value) {
                          final price = num.tryParse(value?.trim() ?? '');

                          if (price == null || price <= 0) {
                            return 'Enter a valid price';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _image,
                        keyboardType: TextInputType.url,
                        decoration: _decoration(
                          'Image URL',
                          hint: 'https://...',
                        ),
                        validator: (value) {
                          final url = value?.trim() ?? '';
                          final uri = Uri.tryParse(url);

                          if (url.isEmpty) {
                            return 'Enter an image URL';
                          }

                          if (uri == null ||
                              !uri.hasScheme ||
                              (uri.scheme != 'https' && uri.scheme != 'http')) {
                            return 'Enter a valid http/https URL';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _description,
                        maxLines: 3,
                        decoration: _decoration('Description'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter a description'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: primary,
                        title: const Text('Available to customers'),
                        value: _available,
                        onChanged: (value) {
                          setState(() => _available = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(_saving ? 'Saving...' : 'Save Menu Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
