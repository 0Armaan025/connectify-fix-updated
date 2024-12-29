import "dart:io";

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:connectify/common/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../../constants/constants.dart';

class UserProfileStorageRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<String> saveUserProfileImage(
    BuildContext context,
    File profileImageFile,
  ) async {
    Storage storage = Storage(client);

    String previewUrl = "";

    await storage.createFile(
      bucketId: APPWRITE_PROFILE_PICS_BUCKET_ID,
      fileId: ID.unique().toString(),
      file: InputFile.fromBytes(
          bytes: profileImageFile.readAsBytesSync(),
          filename: profileImageFile.path.split('/').last),
      permissions: [
        Permission.read('any'),
        Permission.update('any'),
      ],
    ).then((value) async {
      previewUrl = getFilePreviewURL(value.bucketId, value.$id);

      return previewUrl;
    }).onError((error, stackTrace) {
      showSnackBar(context,
          "Some error occurred, please report it to Armaan :) : $error");
      throw Exception(error.toString());
    });

    return previewUrl;
  }
}
