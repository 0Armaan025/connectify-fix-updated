import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:connectify/common/utils/utils.dart';
import 'package:connectify/constants/appwrite_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class UserProfileStorageRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<String> saveUserProfileImage(
    BuildContext context,
    File profileImageFile,
  ) async {
    try {
      // Compress the image
      final compressedImage = await compressImage(profileImageFile);

      Storage storage = Storage(client);

      // Upload the compressed image
      final result = await storage.createFile(
        bucketId: APPWRITE_PROFILE_PICS_BUCKET_ID,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: compressedImage.readAsBytesSync(),
          filename: compressedImage.path.split('/').last,
        ),
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
        ],
      );

      // Generate the preview URL
      final previewUrl = getFilePreviewURL(result.bucketId, result.$id);
      return previewUrl;
    } catch (error) {
      showSnackBar(context, "An error occurred: $error");
      throw Exception(error.toString());
    }
  }

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    int sizeInBytes = file.lengthSync();
    double sizeInKB = sizeInBytes / 1024;
    double sizeInMB = sizeInKB / 1024;
    if (sizeInMB > 5) {
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85, // Adjust quality between 0 and 100 as needed
      );
      if (result != null) {
        return File(result.path);
      } else {
        return file;
      }
    } else {
      return file;
    }
  }
}
