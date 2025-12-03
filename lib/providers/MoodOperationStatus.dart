enum MoodOperationStatus { idle, loading, success, error }

class MoodOperationState {
  final MoodOperationStatus status;
  final String? message;

  MoodOperationState({required this.status, this.message});
}
