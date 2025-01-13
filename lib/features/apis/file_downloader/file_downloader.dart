import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  final Client client;

  FileDownloader(this.client);

  Future<File?> downloadFile(String bucketId, String fileId) async {
    try {
      Storage storage = Storage(client);
      final Uint8List fileBytes = await storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );

      // Determine the file type from its bytes
      final fileType = await getFileTypeFromBytes(fileBytes);

      if (fileType != null) {
        print('File type: $fileType');
      } else {
        print('Unable to determine file type');
      }

      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/temp_file';

      // Save the file in the temporary directory
      final file = File(localPath);
      await file.writeAsBytes(fileBytes);

      return file;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<String?> getFileTypeFromBytes(Uint8List bytes) async {
    final mimeType = lookupMimeType('', headerBytes: bytes);
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) {
        return 'image';
      } else if (mimeType.startsWith('video/')) {
        return 'video';
      }
    }
    return null;
  }
}
