import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  Stream<List<Map<String, dynamic>>> streamCollection(
      String collection, String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => {...d.data() as Map<String, dynamic>, 'id': d.id})
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getTasks(String userId) {
    return streamCollection('tasks', userId);
  }

  Future<DocumentReference<Map<String, dynamic>>> add(
      String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  /// Adiciona com ID definido (útil quando usa Uuid)
  Future<void> addWithId(
      String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).set(data);
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).update(data);
  }

  Future<void> delete(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }
}
