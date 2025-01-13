import 'dart:io';

import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:connectify/features/repositories/database/user_forum_database_repository.dart';
import 'package:flutter/material.dart';

class UserForumDatabaseController {
  Future<void> createForumPost(
      BuildContext context, ForumModal modal, File? mediaFile) async {
    UserForumDatabaseRepository _userForumDatabaseRepository =
        UserForumDatabaseRepository();

    try {
      await _userForumDatabaseRepository.createForumPost(
        context,
        modal,
        mediaFile,
      );
    } catch (e) {
      showSnackBar(context, 'caught issue here: ${e.toString()}');
    }
  }

  Future<List<ForumModal>> getAllForumPosts(BuildContext context) async {
    UserForumDatabaseRepository _userForumDatabaseRepository =
        UserForumDatabaseRepository();

    try {
      return await _userForumDatabaseRepository.fetchForumPosts(context);
    } catch (e) {
      showSnackBar(context, 'caught issue here: ${e.toString()}');
      return [];
    }
  }

  Future<ForumModal?> fetchFormPostByID(
      BuildContext context, String forumID) async {
    UserForumDatabaseRepository _userForumDatabaseRepository =
        UserForumDatabaseRepository();

    try {
      return await _userForumDatabaseRepository.fetchForumPostById(
          context, forumID);
    } catch (e) {
      showSnackBar(context, 'caught issue here: ${e.toString()}');
      return null;
    }
  }
}
