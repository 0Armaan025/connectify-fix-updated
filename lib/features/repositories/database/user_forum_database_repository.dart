import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:connectify/features/controllers/storage/user_forum_storage_controller.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:connectify/features/modals/forum_comment/forum_comment_modal.dart';
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

  Future<String> upvoteForumPost(BuildContext context, String forumID) async {
    final databases = Databases(client);

    final user = await AuthController().getCurrentUser(context);

    if (user != null) {
      final userUUID = await user.$id;
      final result = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_FORUMS_COLLECTION_ID,
        queries: [
          Query.equal('forumID', forumID),
        ],
      );

      if (result.documents.isNotEmpty) {
        // Assuming postID is unique and there's only one matching document
        final forumDoc = result.documents.first;

        List<String> upvotes =
            List<String>.from(forumDoc.data['upvotes'] ?? []);

        if (upvotes.contains(userUUID)) {
          // User has already liked the post, so remove the like
          upvotes.remove(userUUID);
          await databases.updateDocument(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_POSTS_COLLECTION_ID,
            documentId: forumDoc.$id,
            data: {
              'upvotes': upvotes,
            },
            permissions: [
              Permission.update(Role.any()),
              Permission.delete(Role.any()),
              Permission.write(Role.any()),
              Permission.read(Role.any()),
            ],
          );
          return 'downvoted';
        } else {
          // User has not liked the post, so add the like
          upvotes.add(userUUID);
          await databases.updateDocument(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_FORUMS_COLLECTION_ID,
            documentId: forumDoc.$id,
            data: {
              'upvotes': upvotes,
            },
            permissions: [
              Permission.update(Role.any()),
              Permission.delete(Role.any()),
              Permission.write(Role.any()),
              Permission.read(Role.any()),
            ],
          );
          return 'upvoted';
        }
      } else {
        showSnackBar(
            context, 'some error is coming, pwease contact armaan :((');

        return 'error';
      }
    }
    return 'error';
  }

  Future<void> addForumComment(BuildContext context, ForumCommentModal modal,
      File? mediaFile, String forumID) async {
    String previewURL = "";
    if (mediaFile != null) {
      UserForumStorageController _storageController =
          UserForumStorageController();
      previewURL =
          await _storageController.saveUserProfileImage(context, mediaFile);

      String forumCommentID = generateAlphanumericUID();

      final user = await AuthController().getCurrentUser(context);
      if (user != null) {
        final newModal = modal.copyWith(
          mediaUrl: previewURL,
          uuid: user.$id.toString(),
          forumCommentID: forumCommentID,
          createdAt: DateTime.now().toString(),
        );
        await addComment(context, newModal, forumID);
      } else {
        showSnackBar(context, 'some error came, pls msg armaan, sorry!');
      }
    } else {
      String forumCommentID = generateAlphanumericUID();

      final user = await AuthController().getCurrentUser(context);

      if (user != null) {
        final newModal = modal.copyWith(
          mediaUrl: previewURL,
          forumCommentID: forumCommentID,
          uuid: user.$id.toString(),
          createdAt: DateTime.now().toString(),
        );
        await addComment(context, newModal, forumID);
      } else {
        showSnackBar(context, 'some error came, pls msg armaan, sorry!');
      }
    }
  }

  Future<void> addComment(
      BuildContext context, ForumCommentModal modal, String forumID) async {
    final databases = Databases(client);
    final user = await AuthController().getCurrentUser(context);

    if (user != null) {
      try {
        await databases
            .createDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: APPWRITE_FORUM_COMMENTS_COLLECTION_ID,
          documentId: modal.forumCommentID,
          data: modal.toMap(),
        )
            .then((value) async {
          final forumCommentsHere = await databases.listDocuments(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_FORUMS_COLLECTION_ID,
            queries: [
              Query.equal('forumID', forumID),
            ],
          );
          if (forumCommentsHere.documents.isNotEmpty) {
            // Assuming postID is unique and there's only one matching document
            final forumDoc = forumCommentsHere.documents.first;

            List<String> coolComments =
                List<String>.from(forumDoc.data['forumComments'] ?? []);

            coolComments.add(modal.forumCommentID);
            await databases.updateDocument(
              databaseId: APPWRITE_DATABASE_ID,
              collectionId: APPWRITE_POSTS_COLLECTION_ID,
              documentId: forumDoc.$id,
              data: {
                'forumComments': coolComments,
              },
              permissions: [
                Permission.update(Role.any()),
                Permission.delete(Role.any()),
                Permission.write(Role.any()),
                Permission.read(Role.any()),
              ],
            );
          }
        });
      } catch (e) {
        showSnackBar(
            context, 'some error came, pls msg armaan, sorry! ${e.toString()}');
      }
    }
  }

  Future<List<ForumCommentModal>> fetchForumComments(
      BuildContext context, String forumID) async {
    List<ForumCommentModal> forumComments = [];
    final databases = Databases(client);

    try {
      final forumDoc = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_FORUMS_COLLECTION_ID,
        queries: [
          Query.equal('forumID', forumID),
        ],
      );

      if (forumDoc.documents.isNotEmpty) {
        // Assuming postID is unique and there's only one matching document
        final forumDocHere = forumDoc.documents.first;

        List<String> comments =
            List<String>.from(forumDocHere.data['comments'] ?? []);

        List<ForumCommentModal> realComments = [];

        for (String commentID in comments) {
          final commentDoc = await databases.getDocument(
            databaseId: APPWRITE_DATABASE_ID,
            collectionId: APPWRITE_FORUM_COMMENTS_COLLECTION_ID,
            documentId: commentID,
          );

          realComments.add(ForumCommentModal.fromMap(commentDoc.data));
        }

        forumComments = realComments;
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching forum comments: $e');
    }

    return forumComments;
  }
}
