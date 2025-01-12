import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:connectify/features/controllers/database/user_profile_database_controller.dart';
import 'package:connectify/features/controllers/storage/user_post_storage_controller.dart';
import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:connectify/features/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/constants.dart';

class UserPostDatabaseRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<void> createPost(
      BuildContext context, PostModal modal, File? file, bool isImage) async {
    String mediaPreviewURL = '';

    final databases = Databases(client);
    final account = Account(client);
    final models.User? user = await AuthController().getCurrentUser(context);

    if (user != null) {
      final document = await UserProfileDatabaseController()
          .getUserData(context, user.$id.toString());
      try {
        final now = DateTime.now();
        final formattedDate =
            DateFormat('EEE, MMM d, yyyy - hh:mm a').format(now);

        String postID = generateAlphanumericUID();

        if (file != null) {
          mediaPreviewURL = await UserPostStorageController()
              .saveUserProfileImage(context, file, isImage);
        } else {
          mediaPreviewURL = '';
        }

        final updatedModal = modal.copyWith(
          createdAt: formattedDate.toString(),
          postID: postID,
          likes: [""],
          comments: [""],
          uuid: user.$id.toString(),
          mediaUrl: mediaPreviewURL,
        );

        await databases
            .createDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: APPWRITE_POSTS_COLLECTION_ID,
          documentId: ID.unique().toString(),
          data: updatedModal.toMap(),
        )
            .then((value) {
          showSnackBar(context, "Post created successfully!");
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

  Future<List<PostModal>> getAllPosts(BuildContext context) async {
    final databases = Databases(client);

    final posts = await databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_POSTS_COLLECTION_ID,
    );

    List<PostModal> allPosts = [];

    for (models.Document post in posts.documents) {
      allPosts.add(PostModal.fromMap(post.data));
    }

    return allPosts;
  }

  Future<String> likePost(BuildContext context, String postID) async {
    AuthController controller = AuthController();
    final user = await controller.getCurrentUser(context);
    if (user != null) {
      String uuid = user.$id.toString();

      Client client = Client()
          .setEndpoint(APPWRITE_URL) // Replace with your Appwrite endpoint
          .setProject(
              APPWRITE_PROJECT_ID); // Replace with your Appwrite project ID

      Databases databases = Databases(client);

      // Query to find the document with the matching postID field
      final result = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_POSTS_COLLECTION_ID,
        queries: [
          Query.equal('postID', postID),
        ],
      );

      if (result.documents.isNotEmpty) {
        // Assuming postID is unique and there's only one matching document
        final postDoc = result.documents.first;

        List<String> likes = List<String>.from(postDoc.data['likes'] ?? []);

        if (likes.contains(uuid)) {
          // User has already liked the post, so remove the like
          likes.remove(uuid);
          await databases.updateDocument(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_POSTS_COLLECTION_ID,
            documentId: postDoc.$id,
            data: {
              'likes': likes,
            },
            permissions: [
              Permission.update(Role.any()),
              Permission.delete(Role.any()),
              Permission.write(Role.any()),
              Permission.read(Role.any()),
            ],
          );
          return 'disliked';
        } else {
          // User has not liked the post, so add the like
          likes.add(uuid);
          await databases.updateDocument(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_POSTS_COLLECTION_ID,
            documentId: postDoc.$id,
            data: {
              'likes': likes,
            },
            permissions: [
              Permission.update(Role.any()),
              Permission.delete(Role.any()),
              Permission.write(Role.any()),
              Permission.read(Role.any()),
            ],
          );
          return 'liked';
        }
      } else {
        showSnackBar(context, "Post not found.");
      }
    } else {
      showSnackBar(context, "User data not found.");
    }
    return 'error';
  }
}
