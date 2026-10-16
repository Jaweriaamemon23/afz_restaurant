import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/data/menu_catalog.dart';

/// Imports the original 37 starter items without overwriting existing records.
class MenuSeedService {
  MenuSeedService._();
  static final MenuSeedService instance = MenuSeedService._();

  final CollectionReference<Map<String, dynamic>> _menu = FirebaseFirestore
      .instance
      .collection('menuItems');

  String _documentId(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  Future<int> importStarterMenu() async {
    var added = 0;
    final batch = FirebaseFirestore.instance.batch();

    // Check deterministic IDs first so running this more than once is safe.
    for (final item in afzStarterMenu) {
      final id = _documentId(item['name'] as String);
      final ref = _menu.doc(id);
      final existing = await ref.get();
      if (existing.exists) continue;

      batch.set(ref, {
        ...item,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      added++;
    }

    if (added > 0) await batch.commit();
    return added;
  }
}
