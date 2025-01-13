import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/constants/appwrite_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';

class UserForumStorageRepository {
  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  Future<String> saveUserPostMedia(
    BuildContext context,
    File mediaFile,
  ) async {
    try {
      // Check and process the file based on type
      final processedFile = await compressImage(mediaFile);
      // Check final file size
      int sizeInBytes = processedFile.lengthSync();
      double sizeInMB = sizeInBytes / (1024 * 1024);
      if (sizeInMB > 120) {
        showSnackBar(
          context,
          "The image exceeds the maximum allowed size of 120 MB. Please upload a smaller file.",
        );
        throw Exception("File size exceeds 120 MB.");
      }

      Storage storage = Storage(client);

      // Upload the processed file
      final result = await storage.createFile(
        bucketId: APPWRITE_PROFILE_PICS_BUCKET_ID,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: processedFile.readAsBytesSync(),
          filename: processedFile.path.split('/').last,
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
    double sizeInMB = sizeInBytes / (1024 * 1024);
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

  Future<File> compressVideo(File file) async {
    int sizeInBytes = file.lengthSync();
    double sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > 20) {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality, // Adjust quality as needed
        deleteOrigin: false,
      );
      if (info != null && info.file != null) {
        return File(info.file!.path);
      } else {
        return file;
      }
    } else {
      return file;
    }
  }
}
