import 'package:appwrite/models.dart' as models;
import 'package:connectify/features/repositories/storage/user_post_storage_repository.dart';
import 'package:connectify/features/repositories/storage/user_profile_storage_repository.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserPostStorageController {
  Future<String> saveUserProfileImage(
    BuildContext context,
    File file,
    bool isImage,
  ) async {
    UserPostStorageRepository _userProfileStorageRepository =
        UserPostStorageRepository();

    return await _userProfileStorageRepository.saveUserPostMedia(
        context, file, isImage);
  }
}
