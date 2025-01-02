import 'dart:io';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

import 'package:geolocator/geolocator.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

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

  double latitude = 0;
  double longitude = 0;
  Future<String> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      return '';
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permissions are denied, handle accordingly
        showSnackBar(context, "Please grant perm first!");
        return '';
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    latitude = position.latitude;
    longitude = position.longitude;
    setState(() async {});
    String placeName = await getPlaceName(latitude, longitude);
    return placeName;
    // Use the position data
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
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
      return 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
        actions: [
          TextButton(
            onPressed: () {
              // Handle Post Submission
            },
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media Picker
                GestureDetector(
                  onTap: _pickMedia,
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
                          child: const Icon(
                            Icons.add,
                            color: Colors.grey,
                            size: 40,
                          ),
                        )
                      : Container(
                          width: size.width,
                          height: size.height * 0.25,
                          decoration: BoxDecoration(
                            image: isImage
                                ? DecorationImage(
                                    image: FileImage(File(_mediaFile!.path)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: isVideo ? Colors.black : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          child: isVideo
                              ? const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : null,
                        ),
                ),
                const SizedBox(height: 15),

                // Caption Input
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

                // Tags Input
                TextField(
                  controller: _tagsController,
                  style: GoogleFonts.poppins(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Add hashtags (e.g., #nature)',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 15),

                // Location
                GestureDetector(
                  onTap: () async {
                    _location = await _getCurrentLocation(context);
                    setState(() async {
                      // _location = "Sample Location, City";
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        _location,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Privacy Settings
                Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.grey),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedPrivacy,
                      items: <String>['Public', 'Friends Only', 'Private']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPrivacy = value!;
                        });
                      },
                    ),
                  ],
                ),
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
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
