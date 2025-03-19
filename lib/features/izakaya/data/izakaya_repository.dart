import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/izakaya.dart';

part 'izakaya_repository.g.dart';

@riverpod
IzakayaRepository izakayaRepository(Ref ref) {
  return IzakayaRepository(FirebaseFirestore.instance);
}

class IzakayaRepository {
  final FirebaseFirestore _firestore;
  
  IzakayaRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _izakayaCollection =>
      _firestore.collection('izakayas');

  Future<String> create(Izakaya izakaya) async {
    final doc = await _izakayaCollection.add(izakaya.toFirestore());
    return doc.id;
  }

  Future<void> update(Izakaya izakaya) async {
    if (izakaya.id == null) {
      throw ArgumentError('Izakaya id cannot be null for update operation');
    }
    await _izakayaCollection.doc(izakaya.id).update(izakaya.toFirestore());
  }

  Future<void> delete(String id) async {
    await _izakayaCollection.doc(id).delete();
  }

  Future<Izakaya?> get(String id) async {
    final doc = await _izakayaCollection.doc(id).get();
    if (!doc.exists) return null;
    return Izakaya.fromFirestore(doc);
  }

  Stream<List<Izakaya>> watchPublic() {
    return _izakayaCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Izakaya.fromFirestore(doc)).toList());
  }

  Stream<List<Izakaya>> watchUserIzakayas(String userId) {
    return _izakayaCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Izakaya.fromFirestore(doc)).toList());
  }
} 