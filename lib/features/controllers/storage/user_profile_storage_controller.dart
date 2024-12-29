import 'package:appwrite/models.dart' as models;
import 'package:connectify/features/repositories/storage/user_profile_storage_repository.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserProfileStorageController {
  Future<String> saveUserProfileImage(
    BuildContext context,
    File imageFile,
  ) async {
    UserProfileStorageRepository _userProfileStorageRepository =
        UserProfileStorageRepository();

    return await _userProfileStorageRepository.saveUserProfileImage(
        context, imageFile);
  }
}
