import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get db => _db;

  /// Streams a collection filtered by userId and returns a list of maps
  Stream<List<Map<String, dynamic>>> streamCollection(
      String collection, String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  /// Backwards-compatible helper for tasks specifically
  Stream<List<Map<String, dynamic>>> getTasks(String userId) {
    return streamCollection('tasks', userId);
  }

  /// Adds a document to the specified collection.
  Future<DocumentReference<Map<String, dynamic>>> add(
      String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  /// Updates a document in the specified collection by id.
  Future<void> update(String collection, String id, Map<String, dynamic> data) {
    return _db.collection(collection).doc(id).update(data);
  }

  /// Deletes a document in the specified collection by id.
  Future<void> delete(String collection, String id) {
    return _db.collection(collection).doc(id).delete();
  }
}
