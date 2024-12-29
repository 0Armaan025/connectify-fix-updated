import 'package:connectify/common/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:like_button/like_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class PostWidget extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;
  final String? text;

  const PostWidget({
    super.key,
    this.imageUrl,
    this.videoUrl,
    this.text,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool _isFollowed = false;
  late VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _videoController = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          setState(() {});
        });
    } else {
      _videoController = null;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPlayIconVisible = false;
    final size = MediaQuery.of(context).size;

    // Image/Video height adjustment
    double mediaHeight = widget.imageUrl != null ? 450.0 : 300.0;

    Widget _buildMediaContent() {
      if (widget.imageUrl == null && widget.videoUrl == null) {
        return const SizedBox(); // No media content
      }

      return Stack(
        children: [
          // Media (Image or Video)
          Container(
            height: mediaHeight,
            width: double.infinity,
            child: widget.videoUrl != null && _videoController != null
                ? _videoController!.value.isInitialized
                    ? GestureDetector(
                        onTap: () {
                          // Toggle visibility of play icon
                          setState(() {
                            _isPlayIconVisible = true;
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              _isPlayIconVisible = false;
                            });
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator())
                : widget.imageUrl != null
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox(),
          ),

          // User Info Overlay (on top of media)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/128/3177/3177440.png',
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Armaan",
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
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Show options
                  },
                ),
              ],
            ),
          ),

          // Play/Pause Icon (disappears after 3 seconds)
          if (_isPlayIconVisible && widget.videoUrl != null)
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
                    allowScrubbing: true, // Enables scrubbing
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      bufferedColor: Colors.grey.shade400,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Play/Pause Button
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.value.isPlaying
                                ? _videoController!.pause()
                                : _videoController!.play();
                          });
                        },
                      ),
                      // Mute/Unmute Button
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Column(
        children: [
          // Media Section (Only if media exists)
          if (widget.imageUrl != null || widget.videoUrl != null)
            _buildMediaContent(),

          // Text-Only User Info Row
          if (widget.imageUrl == null && widget.videoUrl == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/128/3177/3177440.png',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Armaan",
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
                    likeCount: 665,
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
