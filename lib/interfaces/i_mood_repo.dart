import '../models/mood.dart';

abstract class IMoodsRepository {
  Future<List<Mood>> getMoods(String uid);
  Future<Mood> addMood(String uid, Mood mood);
  Future<Mood> updateMood(String uid, Mood mood);
  Future<String> deleteMood(String uid, String id);
}
