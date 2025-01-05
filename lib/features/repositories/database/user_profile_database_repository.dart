import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/storage/user_profile_storage_controller.dart';
import 'package:connectify/features/modals/user/user_modal.dart';
import 'package:connectify/features/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../constants/appwrite_constants.dart';

class UserProfileDatabaseRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<void> saveUserData(
      BuildContext context, UserModal modal, File imageFile) async {
    final databases = Databases(client);
    final account = Account(client);
    final models.User user = await account.get();

    try {
      final now = DateTime.now();
      final formattedDate =
          DateFormat('EEE, MMM d, yyyy - hh:mm a').format(now);

      // get a previewUrl for the user profile image

      UserProfileStorageController _userProfileStorageController =
          UserProfileStorageController();
      final String profileImageUrl = await _userProfileStorageController
          .saveUserProfileImage(context, imageFile);

      final updatedModal = modal.copyWith(
        realName: user.name,
        blockedUsers: [""],
        createdAt: formattedDate.toString(),
        email: user.email,
        followers: [""],
        following: [""],
        isVerified: false,
        likes: 0,
        notifications: [""],
        uuid: user.$id.toString(),
        profileImageUrl: profileImageUrl,
        status: 'offline',
      );

      final bool _isUserNameTaken =
          await checkUsernameTaken(context, modal.username);

      if (!_isUserNameTaken) {
        final document = databases
            .createDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: APPWRITE_USERS_COLLECTION_ID,
          documentId: user.$id.toString(),
          data: updatedModal.toMap(),
        )
            .then((value) {
          showSnackBar(context, 'User details updated successfully!!');
          moveScreen(context, HomePage(), isPushReplacement: true);
        });
      } else {
        showSnackBar(context, 'Username taken, sorry!');
      }
    } catch (e) {
      showSnackBar(context,
          "Error ocurred, please report it to Armaan :) ${e.toString()}");
    }
  }

  Future<bool> checkUsernameTaken(BuildContext context, String username) async {
    bool _usernameTaken = false;

    try {
      final databases = Databases(client);

      final documents = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: APPWRITE_USERS_COLLECTION_ID,
        queries: [
          Query.equal('username', username),
        ],
      );

      if (documents.documents.isNotEmpty) {
        _usernameTaken = true;
      } else {
        _usernameTaken = false;
      }

      return _usernameTaken;
    } catch (e) {
      showSnackBar(context,
          'please report this error to Armaan, error: ${e.toString()}');
    }

    return _usernameTaken;
  }

  Future<models.Document> getUserData(String uuid) {
    final databases = Databases(client);

    final document = databases.getDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: APPWRITE_USERS_COLLECTION_ID,
      documentId: uuid,
    );

    return document;
  }
}
