import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/authentication/auth_controller.dart';
import 'package:connectify/features/controllers/database/user_post_database_controller.dart';
import 'package:connectify/features/repositories/database/user_post_database_repository.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class CommentTile extends StatefulWidget {
  final String commentID;
  final String commentText;
  final List<String> likes;
  final VoidCallback onLike;
  final String username;
  final String createdAt;
  final String profileImageUrl;
  const CommentTile(
      {super.key,
      required this.commentText,
      required this.likes,
      required this.onLike,
      required this.createdAt,
      required this.profileImageUrl,
      required this.commentID,
      required this.username});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isExpanded = false;
  final int maxWordsLength = 50;
  bool liked = false;

  String displayedText = ""; // Store the text to display
  bool _isLongText = false;
  int likeCount = 0;

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: contentBox(context),
        );
      },
    );
  }

  Widget contentBox(context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report Comment'),
            onTap: () {
              Navigator.pop(context);
              _handleReport();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View User Profile'),
            onTap: () {
              Navigator.pop(context);
              _handleViewProfile();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            title: const Text('Delete comment'),
            onTap: () {
              Navigator.pop(context);
              _handleViewProfile();
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  void _handleReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment reported')),
    );
  }

  void likeComment(BuildContext context, String commentID) async {
    UserPostDatabaseController controller = UserPostDatabaseController();
    try {
      final value = await controller.likeComment(context, commentID);
      if (value == 'liked') {
        liked = true;
      } else if (value == 'disliked') {
        liked = false;
      } else {
        showSnackBar(context, 'Error: Unable to like comment.');
      }
    } catch (error) {
      showSnackBar(context, 'Error liking comment: $error');
    }
  }

  void _handleViewProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing user profile')),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCommentText();
    getCount();
    checkUserExistenceInLikes();
  }

  checkUserExistenceInLikes() async {
    await checkForUser();
  }

  checkForUser() async {
    AuthController _controller = AuthController();

    final user = await _controller.getCurrentUser(context);

    if (user != null) {
      liked = widget.likes.contains(user.$id);
    }
  }

  getCount() {
    getLikeCountHere();
  }

  getLikeCountHere() async {
    likeCount = await getLikeCount(context, widget.commentID);
    setState(() {});
  }

  void _getCommentText() {
    final words = widget.commentText.split(' ');
    _isLongText = words.length > maxWordsLength;

    displayedText = _isLongText
        ? '${words.take(maxWordsLength).join(' ')}...'
        : widget.commentText;
  }

  Future<int> getLikeCount(BuildContext context, String commentID) async {
    UserPostDatabaseRepository _firstTimeRepo = UserPostDatabaseRepository();
    String likesCount =
        await _firstTimeRepo.getCommentLikes(context, commentID);
    return int.parse(likesCount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showOptionsDialog(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 5),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.profileImageUrl),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.username,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.createdAt,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: LikeButton(
                    onTap: (isLiked) async {
                      final wasLiked = liked; // Store the current state
                      try {
                        likeComment(context, widget.commentID);

                        // Update like count and state based on the result
                        setState(() {
                          liked = !wasLiked;
                          if (liked) {
                            likeCount += 1; // Increment count if liked
                          } else {
                            likeCount -= 1; // Decrement count if unliked
                          }
                        });

                        return !wasLiked; // Return the new like state
                      } catch (error) {
                        showSnackBar(
                            context, 'Error liking comment. Try again.');
                        return wasLiked; // Revert to the old state in case of error
                      }
                    },
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
                        color: liked ? Colors.red.shade800 : Colors.grey,
                        size: 30,
                      );
                    },
                    likeCount: likeCount,
                    countBuilder: (int? count, bool isLiked, String text) {
                      final color =
                          isLiked ? Colors.deepPurpleAccent : Colors.grey;
                      return Text(
                        count == 0 ? "0" : text,
                        style: TextStyle(color: color),
                      );
                    },
                    countPostion: CountPostion.bottom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _isExpanded
                  ? widget.commentText
                  : displayedText, // Use displayedText here
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
            if (_isLongText)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue), // Make it blue for better visibility
                ),
              ),
          ],
        ),
      ),
    );
  }
}
