import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:connectify/common/utils/utils.dart';
import 'package:connectify/features/modals/user/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/appwrite_constants.dart';

class UserProfileDatabaseRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<void> saveUserData(BuildContext context, UserModal modal) async {
    final databases = Databases(client);
    final account = Account(client);
    final User user = await account.get();

    try {
      final now = DateTime.now();
      final formattedDate =
          DateFormat('EEE, MMM d, yyyy - hh:mm a').format(now);

      final uuid = generateAlphanumericUID();

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
        uuid: uuid,
        profileImageUrl: '',
        status: 'offline',
      );

      final bool _isUserNameTaken =
          await checkUsernameTaken(context, modal.username);

      if (!_isUserNameTaken) {
        final document = databases
            .createDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: APPWRITE_USERS_COLLECTION_ID,
          documentId: ID.unique().toString(),
          data: updatedModal.toMap(),
        )
            .then((value) {
          showSnackBar(context, 'Sir, done, sir!');
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
}
