import '../models/user_profile.dart';

abstract class IUsersRepository {
  Future<AppUser?> getUser(String uid);
  Future<void> addUser(AppUser user);
}
