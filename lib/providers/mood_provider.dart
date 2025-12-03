import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_state.dart';
import '../models/mood.dart';
import '../repos/mood_repository.dart';
import 'MoodOperationStatus.dart';

class MoodProvider extends ChangeNotifier {
  final MoodRepository _moodsRepo = MoodRepository();

  MoodState _state = MoodState.loading();
  MoodState get state => _state;

  MoodOperationState createMoodState = MoodOperationState(status: MoodOperationStatus.idle);
  MoodOperationState editMoodState = MoodOperationState(status: MoodOperationStatus.idle);

  Future<void> loadMoods() async {
    _state = MoodState.loading();
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _state = MoodState.error('No user signed in');
      notifyListeners();
      return;
    }

    try {
      final moodsList = await _moodsRepo.getMoods(uid);
      final moods = moodsList
          .map((m) => Map<String, Object>.from(m.toMap()))
          .toList();

      _state = MoodState.success(moods);
      notifyListeners();
    } catch (e) {
      _state = MoodState.error('Failed to load moods: $e');
      notifyListeners();
    }
  }

  Future<void> addMood(Mood mood) async {
    createMoodState = MoodOperationState(status: MoodOperationStatus.loading);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      createMoodState = MoodOperationState(status: MoodOperationStatus.error, message: 'No user signed in');
      notifyListeners();
      return;
    }

    try {
      final created = await _moodsRepo.addMood(uid, mood);
      final map = Map<String, Object>.from(created.toMap())..['id'] = created.id ?? '';
      _state.moods.insert(0, map);
      createMoodState = MoodOperationState(status: MoodOperationStatus.success);
    } catch (e) {
      createMoodState = MoodOperationState(status: MoodOperationStatus.error, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> editMood(int index, Mood mood) async {
    editMoodState = MoodOperationState(status: MoodOperationStatus.loading);
    notifyListeners();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      editMoodState = MoodOperationState(status: MoodOperationStatus.error, message: 'No user signed in');
      notifyListeners();
      return;
    }

    try {
      final updated = await _moodsRepo.updateMood(uid, mood);
      _state.moods[index] = Map<String, Object>.from(updated.toMap())..['id'] = updated.id ?? '';
      editMoodState = MoodOperationState(status: MoodOperationStatus.success);
    } catch (e) {
      editMoodState = MoodOperationState(status: MoodOperationStatus.error, message: e.toString());
    }
    notifyListeners();
  }

  Future<void> deleteMood(int index) async {
    if (_state.status != MoodStateStatus.success) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final moodId = _state.moods[index]['id'] as String;
      final deletedId = await _moodsRepo.deleteMood(uid, moodId);
      if (deletedId == moodId) {
        _state.moods.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
    }
  }
}
