import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:connectify/features/controllers/storage/user_forum_storage_controller.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/utils/utils.dart';
import '../../../constants/constants.dart';
import '../../controllers/authentication/auth_controller.dart';
import '../../controllers/database/user_profile_database_controller.dart';
import '../../views/home/home_view.dart';

class UserForumDatabaseRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<void> createForumPost(
      BuildContext context, ForumModal modal, File? mediaFile) async {
    String mediaPreviewURL = '';

    final databases = Databases(client);
    final account = Account(client);
    final models.User? user = await AuthController().getCurrentUser(context);

    if (user != null) {
      try {
        final document = await UserProfileDatabaseController()
            .getUserData(context, user.$id.toString());
        final now = DateTime.now();
        final formattedDate =
            DateFormat('EEE, MMM d, yyyy - hh:mm a').format(now);

        String forumID = generateAlphanumericUID();

        if (mediaFile != null) {
          mediaPreviewURL = await UserForumStorageController()
              .saveUserProfileImage(context, mediaFile);
        } else {
          mediaPreviewURL = '';
        }

        final updatedModal = modal.copyWith(
          createdAt: formattedDate.toString(),
          forumID: forumID,
          uuid: user.$id.toString(),
          mediaUrl: mediaPreviewURL,
        );

        await databases
            .createDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: APPWRITE_FORUMS_COLLECTION_ID,
          documentId: forumID,
          data: updatedModal.toMap(),
        )
            .then((value) {
          showSnackBar(context, "Forum Post created successfully!");

          moveScreen(context, const HomePage());
        });
      } catch (e) {
        showSnackBar(context,
            "Some error ocurred , pwease 2 contact armaan! : ${e.toString()}");
      }
    } else {
      showSnackBar(context,
          "please re-register or something, error sorry contact aRmaan");
    }
  }

  Future<List<ForumModal>> fetchForumPosts(BuildContext context) async {
    List<ForumModal> forumPosts = [];
    final databases = Databases(client);

    try {
      final posts = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_FORUMS_COLLECTION_ID,
        queries: [
          Query.equal('isPublic', true),
        ],
      );

      for (models.Document post in posts.documents) {
        forumPosts.add(ForumModal.fromMap(post.data));
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching forum posts: $e');
    }

    return forumPosts;
  }

  Future<ForumModal?> fetchForumPostById(
      BuildContext context, String forumID) async {
    final databases = Databases(client);

    try {
      final document = await databases.getDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_FORUMS_COLLECTION_ID,
        documentId: forumID,
      );

      return ForumModal.fromMap(document.data);
    } catch (e) {
      // Handle exceptions, e.g., document not found
      print('Error fetching forum post by ID: $e');
      return null;
    }
  }
}
