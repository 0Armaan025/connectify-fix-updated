import 'package:appwrite/models.dart' as models;
import 'package:connectify/features/repositories/storage/user_forum_storage_repository.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class UserForumStorageController {
  Future<String> saveUserProfileImage(
    BuildContext context,
    File file,

  ) async {
    UserForumStorageRepository _userForumStorageRepository =
        UserForumStorageRepository();

    return await _userForumStorageRepository.saveUserPostMedia(
        context, file);
  }
}
