import 'package:connectify/common/utils/normal_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectify/common/buttons/custom_button.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';

class VideoPostScreen extends StatefulWidget {
  const VideoPostScreen({super.key});

  @override
  State<VideoPostScreen> createState() => _VideoPostScreenState();
}

class _VideoPostScreenState extends State<VideoPostScreen> {
  File? _selectedVideo;
  final _descriptionController = TextEditingController();
  late VideoPlayerController? _videoController;
  bool _isMuted = false;

  List<String> _dummyUsers = [
    'armaan025',
    'alice123',
    'johnDoe',
    'alex007',
    'anna',
    'bobbie'
  ];
  List<String> _filteredUsers = [];

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      final fileSize = await video.length();
      const maxFileSize = 100 * 1024 * 1024; // 100 MB

      if (fileSize > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a file smaller than 100 MB.'),
          ),
        );
        return;
      }

      // Video compression (placeholder for actual logic)
      File compressedVideo =
          File(video.path); // Replace with compressed file logic

      setState(() {
        _selectedVideo = compressedVideo;
        _initializeVideoPlayer(compressedVideo);
      });
    }
  }

  void _initializeVideoPlayer(File video) {
    _videoController = VideoPlayerController.file(video)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _toggleMute() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        _isMuted = !_isMuted;
        _videoController!.setVolume(_isMuted ? 0 : 1);
      });
    }
  }

  void _onTextChanged() {
    String text = _descriptionController.text;
    if (text.contains('@')) {
      String query = text.split('@').last; // Get the part after '@'
      setState(() {
        _filteredUsers = _dummyUsers
            .where((user) => user.startsWith(query)) // Filter based on query
            .toList();
      });
    } else {
      setState(() {
        _filteredUsers.clear(); // Clear suggestions when @ is not found
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onTextChanged);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Pick a Video'),
              ),
              const SizedBox(height: 20),
              if (_selectedVideo != null) ...[
                if (_videoController != null &&
                    _videoController!.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        VideoPlayer(_videoController!),
                        VideoProgressIndicator(_videoController!,
                            allowScrubbing: true),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                            ),
                            onPressed: _toggleMute,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            _videoController!.value.isPlaying
                                ? await _videoController!.pause()
                                : await _videoController!.play();
                            setState(() {});
                          },
                          child: Positioned(
                            left: MediaQuery.of(context).size.width * 0.3,
                            top: MediaQuery.of(context).size.height * 0.25,
                            child: _videoController!.value.isPlaying
                                ? Icon(Icons.play_arrow, size: 100)
                                : Icon(Icons.pause_circle, size: 100),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: const CircularProgressIndicator()),
              ] else
                const Text(
                  'No video selected',
                  style: TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 20),

              // Caption Input with User Mentioning
              TextFormField(
                maxLines: 3,
                controller: _descriptionController,
                maxLength: 80,
                decoration: InputDecoration(
                  hintText: 'Add a description (max 80 words)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // User Mentioning Dropdown
              if (_filteredUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  height: 150,
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '@${_filteredUsers[index]}',
                          style: const TextStyle(
                              color: Colors.blue), 
                        ),
                        onTap: () {
                          setState(() {
                            _descriptionController.text =
                                _descriptionController.text.replaceRange(
                                    _descriptionController.text
                                            .lastIndexOf('@') +
                                        1,
                                    _descriptionController.text.length,
                                    _filteredUsers[index]);
                            _filteredUsers
                                .clear(); // Clear suggestions after selection
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              CustomButtonWidget(
                text: "Post! yay",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
