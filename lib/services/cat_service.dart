import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/models/cat.dart';

class CatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Cat>> getCats() {
    return _firestore.collection('cats').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<Cat>> searchCats(String query, {String? orderBy, bool descending = false}) async {
    Query collection = _firestore.collection('cats');

    if (query.isNotEmpty) {
      collection = collection.where('name_lowercase', isGreaterThanOrEqualTo: query.toLowerCase())
                           .where('name_lowercase', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff');
    }

    if (orderBy != null) {
      collection = collection.orderBy(orderBy, descending: descending);
    }
    
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => Cat.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> updateCatStatus(String catId, String status) async {
    await _firestore.collection('cats').doc(catId).update({'status': status});
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

  Future<void> requestAdoption(String userId, String catId) async {
    await _firestore.collection('adoption_requests').add({
      'userId': userId,
      'catId': catId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}