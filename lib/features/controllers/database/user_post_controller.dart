import 'dart:io';

import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:connectify/features/repositories/database/user_post_database_repository.dart';
import 'package:flutter/material.dart';

class UserPostDatabaseController {
  final UserPostDatabaseRepository _userPostRepository =
      UserPostDatabaseRepository();

  Future<void> createPost(
      BuildContext context, PostModal modal, File? file, bool isImage) async {
    await _userPostRepository.createPost(context, modal, file, isImage);
  }
}
