import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/i_user_repo.dart';
import '../models/user_profile.dart';

class UsersRepository implements IUsersRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw 'Error fetching user data: $e';
    }
  }

  Future<void> addUser(AppUser user) async {
    try {
      await usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw 'Error setting user data: $e';
    }
  }
}
