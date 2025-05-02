import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveImageUrl(String imageUrl) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).set({
        'profile_image': imageUrl,
        'uploaded_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
