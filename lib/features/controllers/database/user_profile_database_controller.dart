import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/modals/user/user_modal.dart';
import 'package:connectify/features/repositories/database/user_profile_database_repository.dart';
import 'package:connectify/features/views/profile_set_up/profile_set_up_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:appwrite/models.dart' as models;

class UserProfileDatabaseController {
  final UserProfileDatabaseRepository _userProfileDatabaseRepository =
      UserProfileDatabaseRepository();

  Future<void> setUpProfile(
      BuildContext context, UserModal modal, File imageFile) async {
    await _userProfileDatabaseRepository.saveUserData(
        context, modal, imageFile);
  }

  Future<models.Document> getUserData(BuildContext context, String uuid) async {
    final document = await _userProfileDatabaseRepository
        .getUserData(uuid)
        .onError((error, stackTrace) {
      if (error.toString().contains("404")) {
        moveScreen(context, const ProfileSetUpPage());
      } else {}

      throw ();
    });
    return document;
  }

  Future<List<models.Document>> getAllUsersData() async {
    final documents = await _userProfileDatabaseRepository.getAllUsers();
    return documents;
  }
}
