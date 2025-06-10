import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/models/cat.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addCat(Map<String, dynamic> catData) async {
    await _firestore.collection('cats').add(catData);
  }

  Future<void> updateCat(String catId, Map<String, dynamic> catData) async {
    await _firestore.collection('cats').doc(catId).update(catData);
  }

  Future<void> deleteCat(String catId) async {
    await _firestore.collection('cats').doc(catId).delete();
  }

  Stream<List<Cat>> getUserCats(String userId) {
    return _firestore
        .collection('cats')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data())).toList();
    });
  }

  Stream<List<Cat>> getAvailableCats() {
    final currentUser = _auth.currentUser;
    return _firestore.collection('cats').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data())).where((cat) {
        final isAvailable = cat.status == 'Disponível';
        final isMyAdoption = cat.status == 'Adoção em andamento' && cat.adopterId == currentUser?.uid;
        return isAvailable || isMyAdoption;
      }).toList();
    });
  }

  Stream<List<Cat>> getMyAdoptions(String userId) {
    return _firestore
        .collection('cats')
        .where('status', isEqualTo: 'Adoção em andamento')
        .where('adopterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<Cat>> searchCats(String query, {String? orderBy, bool descending = false}) async {
    Query collection = _firestore.collection('cats').where('status', isEqualTo: 'Disponível');

    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isNotEmpty) {
      collection = collection
          .orderBy('name_lowercase')
          .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
          .where('name_lowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    } else if (orderBy != null && orderBy.isNotEmpty) {
      collection = collection.orderBy(orderBy, descending: descending);
    }

    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> requestAdoption(String userId, String catId) async {
    await _firestore.collection('adoption_requests').add({
      'userId': userId,
      'catId': catId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('cats').doc(catId).update({
      'status': 'Adoção em andamento',
      'adopterId': userId,
    });
  }

  Future<void> addFavorite(String userId, String catId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(catId).set({});
  }

  Future<void> removeFavorite(String userId, String catId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(catId).delete();
  }

  Stream<bool> isFavorite(String userId, String catId) {
    return _firestore.collection('users').doc(userId).collection('favorites').doc(catId).snapshots().map((snapshot) => snapshot.exists);
  }

  Stream<List<Cat>> getFavoriteCats(String userId) {
    final favoritesStream = _firestore.collection('users').doc(userId).collection('favorites').snapshots();

    return favoritesStream.asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      final catIds = snapshot.docs.map((doc) => doc.id).toList();
      final catsSnapshot = await _firestore.collection('cats').where(FieldPath.documentId, whereIn: catIds).get();

      return catsSnapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data())).toList();
    });
  }
}