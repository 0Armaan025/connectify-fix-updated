import 'package:connectify/features/modals/user/user_modal.dart';
import 'package:connectify/features/repositories/database/user_profile_database_repository.dart';
import 'package:flutter/material.dart';

class UserProfileDatabaseController {
  final UserProfileDatabaseRepository _userProfileDatabaseRepository =
      UserProfileDatabaseRepository();

  Future<void> setUpProfile(BuildContext context, UserModal modal) async {
    await _userProfileDatabaseRepository.saveUserData(context, modal);
  }
}
