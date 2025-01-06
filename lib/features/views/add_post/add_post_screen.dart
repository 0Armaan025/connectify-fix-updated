import 'dart:developer';
import 'dart:io';
import 'package:connectify/common/buttons/custom_button.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:connectify/features/controllers/database/user_post_database_controller.dart';
import 'package:connectify/features/modals/post/post_modal.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../../constants/constants.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _selectedPrivacy = 'Public';
  String _location = "Add Location";
  XFile? _mediaFile;
  bool isVideo = false;
  bool isImage = false;
  bool isLoadingLocation = false;
  VideoPlayerController? _videoController;

  double latitude = 0;
  double longitude = 0;

  Future<String> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showSnackBar(context, 'Turn on your location services, pretty please.');
      return '';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showSnackBar(context, "Please grant location permission first!");
        return '';
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    latitude = position.latitude;
    longitude = position.longitude;
    setState(() {
      isLoadingLocation = true;
    });
    String placeName = await getPlaceName(latitude, longitude);
    setState(() {
      isLoadingLocation = false;
    });
    return placeName;
  }

  Future<void> createPost(BuildContext context) async {
    setState(() {
      loading = true;
    });
    File mediaFile = File(_mediaFile!.path);

    if (_captionController.text.isEmpty && _mediaFile != null) {
    } else if (_mediaFile == null && _captionController.text.isEmpty) {
      showSnackBar(context, 'Please write a caption!');
    } else {
      final user = await AuthController().getCurrentUser(context);
      showSnackBar(context, user!.$id);
      PostModal modal = PostModal(
          postID: '',
          uuid: '',
          comments: [""],
          location: _location == "" ? "No location specified!" : _location,
          likes: [""],
          caption: _captionController.text,
          mediaUrl: '',
          createdAt: '');
      UserPostDatabaseController _controller = UserPostDatabaseController();

      await _controller.createPost(context, modal, mediaFile, isImage);
      setState(() {
        loading = false;
      });
    }
  }

  Future<String> getPlaceName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.name}, ${place.locality}, ${place.country}';
      } else {
        return 'No address found';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: SafeArea(
          child: loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Center(
                      child: Text(
                        "Posting...",
                        style: GoogleFonts.poppins(color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_mediaFile != null) {
                            if (isImage) {
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: Image.file(
                                    File(_mediaFile!.path),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            } else if (isVideo && _videoController != null) {
                              await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: _mediaFile == null
                            ? Container(
                                width: size.width,
                                height: size.height * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    _pickMedia();
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              )
                            : Container(
                                width: size.width,
                                height: size.height * 0.25,
                                decoration: BoxDecoration(
                                  image: isImage
                                      ? DecorationImage(
                                          image:
                                              FileImage(File(_mediaFile!.path)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: isVideo ? Colors.black : null,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade300, width: 1),
                                ),
                                child: isVideo && _videoController != null
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (_videoController!
                                                .value.isPlaying) {
                                              _videoController!.pause();
                                            } else {
                                              _videoController!.play();
                                            }
                                          });
                                        },
                                        child: Center(
                                          child: Icon(
                                            _videoController!.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                      ),
                      const SizedBox(height: 7.5),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Media is optional, but caption is not :) (-Armaan)",
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7.5),
                      TextField(
                        controller: _captionController,
                        maxLength: 200,
                        maxLines: null,
                        style: GoogleFonts.poppins(fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () async {
                          _location = await _getCurrentLocation(context);
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 10),
                            isLoadingLocation
                                ? CircularProgressIndicator()
                                : Text(
                                    _location,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      CustomButtonWidget(
                        text: "Post!",
                        onPressed: () {
                          createPost(context);
                        },
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final selectedFile = await picker.pickMedia();

    if (selectedFile != null) {
      setState(() {
        _mediaFile = selectedFile;
        isVideo = selectedFile.path.endsWith('.mp4') ||
            selectedFile.path.endsWith('.mov');
        isImage = selectedFile.path.endsWith('.jpeg') ||
            selectedFile.path.endsWith(".jpg") ||
            selectedFile.path.endsWith(".png");
        if (isVideo) {
          _videoController = VideoPlayerController.file(File(selectedFile.path))
            ..initialize().then((_) {
              setState(() {});
            });
        }
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
}
