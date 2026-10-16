import 'package:cloud_firestore/cloud_firestore.dart';

class MenuService {
  MenuService._();

  static final MenuService instance = MenuService._();

  final CollectionReference<Map<String, dynamic>> _menu = FirebaseFirestore
      .instance
      .collection('menuItems');

  Stream<List<Map<String, dynamic>>> watchMenuItems() {
    return _menu.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> watchAvailableMenuItems() {
    return _menu.where('isAvailable', isEqualTo: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<void> addMenuItem(Map<String, dynamic> item) async {
    await _menu.add({
      ...item,
      'isAvailable': item['isAvailable'] ?? true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMenuItem(String id, Map<String, dynamic> item) async {
    await _menu.doc(id).update({
      ...item,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMenuItem(String id) async {
    await _menu.doc(id).delete();
  }

  Future<void> setAvailability(String id, bool isAvailable) async {
    await _menu.doc(id).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
