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

  Widget _buildMediaContent() {
    if (widget.imageUrl != null) {
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              // Implement image enlarging here
            },
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (widget.text != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.text!,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
        ],
      );
    } else if (widget.videoUrl != null) {
      return Column(
        children: [
          Stack(
            children: [
              if (_videoController != null &&
                  _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Row(
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
              ),
            ],
          ),
          if (widget.text != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.text!,
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
        ],
      );
    } else if (widget.text != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.text!,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: HexColor("#333333"),
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
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
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isFollowed = !_isFollowed;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
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
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),
          // Media Content
          _buildMediaContent(),
          // Interaction Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  LikeButton(
                    size: 30,
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
                    ),
                    onPressed: () {
                      // Show comments
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.share,
                  color: Colors.grey.shade700,
                ),
                onPressed: () {
                  Share.share('Check this out!');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
