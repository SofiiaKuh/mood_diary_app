import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_diary_app/interfaces/i_mood_repo.dart';
import '../models/mood.dart';

class MoodRepository implements IMoodsRepository{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _moodsRef(String uid) {
    return _db.collection('users').doc(uid).collection('moods');
  }

  @override
  Future<List<Mood>> getMoods(String uid) async {
    final snapshot = await _moodsRef(uid).orderBy('date', descending: true).get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          final mapWithId = {...data, 'id': doc.id};
          return Mood.fromMap(mapWithId);
        })
        .toList();
  }

  @override
  Future<Mood> addMood(String uid, Mood mood) async {
    final docRef = _moodsRef(uid).doc();
    final map = {...mood.toMap(), 'id': docRef.id};
    await docRef.set(map);
    return Mood.fromMap(map);
  }

  @override
  Future<Mood> updateMood(String uid, Mood mood) async {
    if (mood.id == null || mood.id!.isEmpty) {
      throw ArgumentError('Mood.id is null or empty. Cannot update without id.');
    }
    final docRef = _moodsRef(uid).doc(mood.id);
    await docRef.update(mood.toMap());
    final snapshot = await docRef.get();
    final updatedMap = {...(snapshot.data() ?? {}), 'id': docRef.id};
    return Mood.fromMap(updatedMap);
  }

  @override
  Future<String> deleteMood(String uid, String moodId) async {
    await _moodsRef(uid).doc(moodId).delete();
    return moodId;
  }
}
