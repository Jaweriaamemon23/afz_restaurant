import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDataService {
  CustomerDataService._();

  static final CustomerDataService instance = CustomerDataService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _dataDocument {
    final uid = _userId;

    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('customerData')
        .doc('preferences');
  }

  Future<Map<String, dynamic>> loadCustomerData() async {
    final document = _dataDocument;

    if (document == null) {
      return {
        'cartItems': <Map<String, dynamic>>[],
        'favoriteItems': <Map<String, dynamic>>[],
      };
    }

    final snapshot = await document.get();
    final data = snapshot.data() ?? {};

    return {
      'cartItems': _convertItems(data['cartItems']),
      'favoriteItems': _convertItems(data['favoriteItems']),
    };
  }

  List<Map<String, dynamic>> _convertItems(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> saveCart(List<Map<String, dynamic>> items) async {
    final document = _dataDocument;

    if (document == null) return;

    await document.set({
      'cartItems': items
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFavorites(List<Map<String, dynamic>> items) async {
    final document = _dataDocument;

    if (document == null) return;

    await document.set({
      'favoriteItems': items
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearCustomerData() async {
    final document = _dataDocument;

    if (document == null) return;

    await document.set({
      'cartItems': <Map<String, dynamic>>[],
      'favoriteItems': <Map<String, dynamic>>[],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
