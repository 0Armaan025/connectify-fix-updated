import 'package:appwrite/appwrite.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/common/utils/post_widget_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import '../../constants/appwrite_constants.dart';
import '../../features/apis/file_downloader/file_downloader.dart';

class PostWidget extends StatefulWidget {
  final String username;
  final String? imageUrl;
  final String? videoUrl;
  final String? text;
  final String profileImageUrl;
  final String createdAt;
  final String? mediaUrl;
  final int likes;
  final List<String> comments;

  const PostWidget({
    super.key,
    this.imageUrl,
    this.videoUrl,
    this.text,
    this.mediaUrl,
    required this.username,
    required this.profileImageUrl,
    required this.likes,
    required this.createdAt,
    required this.comments,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isFollowed = false;
  VideoPlayerController? _videoController;
  bool isVideo = false;
  bool isLoadingMedia = true;
  bool _isPlayIconVisible = false;
  bool _isPlaying = false;

  String BUCKET_ID = "";
  String FILE_ID = "";
  late FileDownloader _fileDownloader;

  Client client =
      Client().setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID);

  @override
  void initState() {
    super.initState();
    _fileDownloader =
        FileDownloader(client); // Assuming client is already initialized

    if (widget.mediaUrl != null) {
      extractBucketAndFileId(widget.mediaUrl);
      determineFileType(widget.mediaUrl!);
    }
  }

  extractBucketAndFileId(String? url) {
    final uri = Uri.parse(url!);

    final pathSegments = uri.pathSegments;

    if (pathSegments.length >= 5 &&
        pathSegments[0] == 'v1' &&
        pathSegments[1] == 'storage' &&
        pathSegments[2] == 'buckets') {
      final bucketId = pathSegments[3];
      final fileId = pathSegments[5];
      BUCKET_ID = bucketId;
      FILE_ID = fileId;
      setState(() {});
    }
  }

  Future<String> getLocalPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<void> determineFileType(String url) async {
    try {
      final path = await getLocalPath();

      final file = await _fileDownloader.downloadFile(
          BUCKET_ID, // Replace with actual bucket ID
          FILE_ID, // Replace with actual file ID
          "$path${DateTime.now().microsecondsSinceEpoch.toString()}");

      if (file != null) {
        final fileBytes = await file.readAsBytes();
        final fileType = await _fileDownloader.getFileTypeFromBytes(fileBytes);

        setState(() {
          isVideo = fileType == 'video';
          isLoadingMedia = false;
        });

        if (isVideo) {
          _videoController = VideoPlayerController.file(file)
            ..initialize().then((_) {
              setState(() {
                isLoadingMedia = false;
              });
            });

          _videoController!.play();
        } else {
          // Handle image case if needed
          isLoadingMedia = false;
        }
      }
    } catch (e) {
      print('Error determining file type: $e');
      setState(() {
        isLoadingMedia = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildMediaContent() {
    if (isLoadingMedia) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.mediaUrl == null) {
      return const SizedBox(); // No media content
    }

    double mediaHeight = widget.imageUrl != null ? 550.0 : 400.0;

    return Stack(
      children: [
        Container(
          height: mediaHeight,
          width: double.infinity,
          child: isVideo
              ? _videoController != null &&
                      _videoController!.value.isInitialized
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _videoController!.pause();
                          _isPlayIconVisible = true;
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            _videoController!.play();
                            _isPlayIconVisible = false;
                          });
                        });
                      },
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio * 4,
                        child: Stack(
                          children: [
                            VideoPlayer(
                              _videoController!,
                            ),

                            // Play/Pause Button
                            if (_isPlayIconVisible)
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_videoController!.value.isPlaying) {
                                        _videoController!.pause();
                                      } else {
                                        _videoController!.play();
                                      }
                                    });
                                  },
                                  child: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    size: 50,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),

                            // Mute/Unmute Button
                            Positioned(
                              top: 50,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  _videoController!.value.volume > 0
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.setVolume(
                                        _videoController!.value.volume > 0
                                            ? 0
                                            : 1);
                                  });
                                },
                              ),
                            ),

                            // Time Indicator and Progress Bar
                            Positioned(
                              bottom: 10,
                              left: 10,
                              right: 10,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatDuration(
                                            _videoController!.value.position),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        formatDuration(
                                            _videoController!.value.duration),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                      playedColor: Colors.blue,
                                      bufferedColor: Colors.grey.shade400,
                                      backgroundColor: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())
              : Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.mediaUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
        ),

        // User Info Overlay
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(widget.profileImageUrl),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFollowed = !_isFollowed;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isFollowed
                            ? HexColor("#87CEEB")
                            : HexColor("#e1e2e3"),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _isFollowed ? "Followed ✔️" : "Follow",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // Show options
                },
              ),
            ],
          ),
        ),
        // Play/Pause Icon
        if (_isPlayIconVisible && widget.videoUrl != null)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    showSnackBar(context, "Pausing");
                    _videoController!.pause();
                  } else {
                    showSnackBar(context, "playing");
                    _videoController!.play();
                  }
                });
              },
              child: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
                size: 50,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        // Video Progress Bar
        if (widget.videoUrl != null)
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.blue,
                    bufferedColor: Colors.grey.shade400,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          showSnackBar(context, "playing 2");
                          _videoController!.value.isPlaying
                              ? _videoController!.pause()
                              : _videoController!.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        _videoController!.value.volume > 0
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _videoController!.setVolume(
                              _videoController!.value.volume > 0 ? 0 : 1);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Column(
        children: [
          if (widget.mediaUrl != null ||
              widget.videoUrl != null ||
              widget.mediaUrl != null)
            _buildMediaContent(),
          // Text-Only User Info Row
          if (widget.imageUrl == null &&
              widget.videoUrl == null &&
              widget.mediaUrl == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      widget.profileImageUrl,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Username without media content
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFollowed = !_isFollowed;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isFollowed
                                ? HexColor("#87CEEB")
                                : HexColor("#e1e2e3"),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _isFollowed ? "Followed ✔️" : "Follow",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {
                      // Show options
                    },
                  ),
                ],
              ),
            ),
          // Text Below Media
          if (widget.text != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.text!,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 8),
            alignment: Alignment.centerRight,
            child: Text(
              "Posted 2 hours ago",
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  LikeButton(
                    countPostion: CountPostion.bottom,
                    size: 25,
                    circleColor: const CircleColor(
                        start: Color(0xff00ddff), end: Color(0xff0099cc)),
                    bubblesColor: const BubblesColor(
                      dotPrimaryColor: Color(0xff33b5e5),
                      dotSecondaryColor: Color(0xff0099cc),
                    ),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 30,
                      );
                    },
                    likeCount: widget.likes,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.chat_bubble_2,
                      color: Colors.grey.shade700,
                      size: 25,
                    ),
                    onPressed: () {
                      showComments(context);
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.share,
                  color: Colors.grey.shade700,
                  size: 25,
                ),
                onPressed: () {
                  Share.share(
                      'yeah, this is in development, Sorry\n -Armaan :(');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
