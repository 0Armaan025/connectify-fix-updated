import 'dart:io';

import 'package:connectify/features/controllers/storage/user_post_storage_controller.dart';
import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:connectify/features/modals/post_comment/post_comment_modal.dart';
import 'package:connectify/features/repositories/database/user_post_database_repository.dart';
import 'package:flutter/material.dart';

class UserPostDatabaseController {
  final UserPostDatabaseRepository _userPostRepository =
      UserPostDatabaseRepository();

  Future<void> createPost(
      BuildContext context, PostModal modal, File? file, bool isImage) async {
    await _userPostRepository.createPost(context, modal, file, isImage);
  }

  Future<List<PostModal>> getAllPosts(BuildContext context) async {
    final posts = await _userPostRepository.getAllPosts(context);
    return posts;
  }

  Future<String> likePost(BuildContext context, String postID) async {
    UserPostDatabaseRepository _repo = UserPostDatabaseRepository();
    return await _repo.likePost(context, postID);
  }

  Future<String> likeComment(BuildContext context, String postID) async {
    UserPostDatabaseController _repo = UserPostDatabaseController();
    return await _repo.likeComment(context, postID);
  }

  Future<void> commentOnPost(
      BuildContext context, String postID, PostCommentModal modal) async {
    UserPostDatabaseRepository _repo = UserPostDatabaseRepository();
    return await _repo.commentOnPost(context, modal, postID);
  }

  Future<List<PostCommentModal>> getComments(
      BuildContext context, String postID) async {
    UserPostDatabaseRepository _repo = UserPostDatabaseRepository();
    return await _repo.getComments(context, postID);
  }
}
