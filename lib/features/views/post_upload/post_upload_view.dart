import 'dart:io';
import 'dart:typed_data';

import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/views/add_forum_post/add_forum_post_view.dart';
import 'package:connectify/features/views/add_post/add_post_screen.dart';
import 'package:connectify/features/views/image_post/image_post_view.dart';
import 'package:connectify/features/views/text_post/text_post_view.dart';
import 'package:connectify/features/views/video_post/video_post_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PostUploadView extends StatefulWidget {
  const PostUploadView({super.key});

  @override
  State<PostUploadView> createState() => PostUploadViewState();
}

class PostUploadViewState extends State<PostUploadView> {
  File? mediaFile;

  Future<File?> pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      File image = File(pickedImage.path);

      // Compress the image
      return await compressImage(image);
    } else {
      showSnackBar(context, "Please choose an image!");
      return null;
    }
  }

  Future<File?> pickMedia(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedMedia = await picker.pickMedia();

    if (pickedMedia != null) {
      File media = File(pickedMedia.path);
      return media;
    } else {
      showSnackBar(context, "Please choose a media file!");
      return null;
    }
  }

  Future<File?> compressImage(File image) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80,
      rotate: 0,
    );

    if (result != null) {
      File compressedFile = File(image.path)..writeAsBytesSync(result);
      return compressedFile;
    } else {
      print("Compression failed.");
      return null;
    }
  }

  void showOptionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose an Option',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                  leading:
                      Icon(CupertinoIcons.create, color: Colors.deepPurple),
                  title: Text(
                    'Post',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () async {
                    moveScreen(context, const AddPostScreen());
                  }),
              ListTile(
                leading: const Icon(Icons.forum, color: Colors.blue),
                title: const Text('Forum'),
                onTap: () async {
                  moveScreen(context, const AddForumPostView());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isValidMediaFile(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'mp4':
      case 'mov':
      case 'avi':
        return true;
      default:
        return false;
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.75,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      showOptionDialog(context);
                    },
                    icon: const Icon(
                      Icons.upload,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              mediaFile != null
                  ? Image.file(mediaFile!)
                  : const SizedBox
                      .shrink(), // Show the selected image if available
            ],
          ),
        ),
      ),
    );
  }
}
