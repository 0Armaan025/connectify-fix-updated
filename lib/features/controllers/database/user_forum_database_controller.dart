import 'dart:io';

import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:connectify/features/repositories/database/user_forum_database_repository.dart';
import 'package:flutter/material.dart';

class UserForumDatabaseController {
  Future<void> createForumPost(BuildContext context, ForumModal modal,
      File? mediaFile, bool isImage, bool isPdf) async {
    UserForumDatabaseRepository _userForumDatabaseRepository =
        UserForumDatabaseRepository();

    try {
      await _userForumDatabaseRepository.createForumPost(
          context, modal, mediaFile, isImage, isPdf);
    } catch (e) {
      showSnackBar(context, 'caught issue here: ${e.toString()}');
    }
  }
}
