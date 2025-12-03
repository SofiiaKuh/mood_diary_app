enum MoodStateStatus { loading, success, error }

class MoodState {
  final MoodStateStatus status;
  final List<Map<String, Object>> moods;
  final String? errorMessage;

  MoodState({
    required this.status,
    required this.moods,
    this.errorMessage,
  });

  factory MoodState.loading() => MoodState(status: MoodStateStatus.loading, moods: []);
  factory MoodState.success(List<Map<String, Object>> moods) =>
      MoodState(status: MoodStateStatus.success, moods: moods);
  factory MoodState.error(String message) =>
      MoodState(status: MoodStateStatus.error, moods: [], errorMessage: message);
}
